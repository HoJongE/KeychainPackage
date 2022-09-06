import Foundation

public final class PasswordKeychainManager {

    private let service: String
    private let appGroup: String?

    public init(service: String, appGroup: String? = nil) {
        self.service = service
        self.appGroup = appGroup
    }

}

// MARK: - Public Interface
// MARK: - Async/Await extension
public extension PasswordKeychainManager {

    func savePassword(_ password: String, for userAccount: String) async throws {
        try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            savePassword(password, for: userAccount) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    func getPassword(for userAccount: String) async throws -> String? {
        let password: String? = try await withCheckedThrowingContinuation { [self] continuation in
            getPassword(for: userAccount) { password, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: password)
            }
        }
        return password
    }

    func removePassword(for userAccount: String) async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removePassword(for: userAccount) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    func removeAllPassword() async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removeAllPassword { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
// MARK: - Completion handler extension
public extension PasswordKeychainManager {
    func savePassword(_ password: String, for userAccount: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            // password 를 데이터 convert 에 실패하면... 바로 completion handler 실행
            guard let encodedPassword: Data = try? self.parsePasswordToData(password) else {
                completion?(KeyChainError.stringToDataConversionError)
                return
            }
            let passwordQuery: PasswordQuery = PasswordQuery(service: self.service, appGroup: self.appGroup)

            var query = passwordQuery.query
            query[String(kSecAttrAccount)] = userAccount
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            switch status {
            case errSecSuccess:
                var attributesToUpdate: [String: Any] = [:]
                attributesToUpdate[String(kSecValueData)] = encodedPassword
                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

                if status != errSecSuccess {
                    completion?(self.error(from: status))
                } else {
                    completion?(nil)
                }
            case errSecItemNotFound:
                query[String(kSecValueData)] = encodedPassword
                let status = SecItemAdd(query as CFDictionary, nil)
                if status != errSecSuccess {
                    completion?(self.error(from: status))
                } else {
                    completion?(nil)
                }
            default:
                completion?(self.error(from: status))
            }
        }
    }

    func getPassword(for userAccount: String, completion: ((String? ,Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            let query = self.makeFindPasswordQuery(for: userAccount)

            var queryResult: AnyObject?
            let status: OSStatus = withUnsafeMutablePointer(to: &queryResult) {
                SecItemCopyMatching(query, $0)
            }

            switch status {
            case errSecSuccess:
                guard let quriedItem = queryResult as? [String: Any],
                      let passwordData = quriedItem[String(kSecValueData)] as? Data,
                      let password = String(data: passwordData, encoding: .utf8)
                else {
                    completion?(nil, KeyChainError.dataToStringConversionError)
                    return
                }
                completion?(password, nil)
            case errSecItemNotFound:
                completion?(nil, nil)
            default:
                completion?(nil, self.error(from: status))
            }
        }
    }

    func removePassword(for userAccount: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            var query = PasswordQuery(service: service, appGroup: appGroup).query
            query[String(kSecAttrAccount)] = userAccount
            let status = SecItemDelete(query as CFDictionary)

            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(error(from: status))
                return
            }
            completion?(nil)
        }
    }

    func removeAllPassword(completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            let query = PasswordQuery(service: service, appGroup: appGroup).query
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(error(from: status))
                return
            }
            completion?(nil)
        }
    }
}

// MARK: - Implementation
private extension PasswordKeychainManager {

    func error(from status: OSStatus) -> KeyChainError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return KeyChainError.unknownError(message: message)
    }

    func parsePasswordToData(_ password: String) throws -> Data {
        guard let encodedPassword = password.data(using: .utf8) else {
            throw KeyChainError.stringToDataConversionError
        }

        return encodedPassword
    }

    func makeFindPasswordQuery(for userAccount: String) -> CFDictionary {
        let passwordQuery = PasswordQuery(service: service, appGroup: appGroup)
        var ret = passwordQuery.query
        ret[String(kSecMatchLimit)] = kSecMatchLimitOne
        ret[String(kSecReturnAttributes)] = kCFBooleanTrue
        ret[String(kSecReturnData)] = kCFBooleanTrue
        ret[String(kSecAttrAccount)] = userAccount

        return ret as CFDictionary
    }

}
