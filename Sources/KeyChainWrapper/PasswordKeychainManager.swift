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
public extension PasswordKeychainManager {

    func savePassword(_ password: String, for userAccount: String) async throws {

        let encodedPassword: Data = try parsePasswordToData(password)
        let passwordQuery: PasswordQuery = PasswordQuery(service: service, appGroup: appGroup)

        var query = passwordQuery.query
        query[String(kSecAttrAccount)] = userAccount

        var status: OSStatus = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                let status = SecItemCopyMatching(query as CFDictionary, nil)
                continuation.resume(with: Result.success(status))
            }
        }

        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedPassword

            status = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInteractive).async {
                    let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                    continuation.resume(with: Result.success(status))
                }
            }

            if status != errSecSuccess {
                throw error(from: status)
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword
            status = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInteractive).async {
                    let status = SecItemAdd(query as CFDictionary, nil)
                    continuation.resume(with: Result.success(status))
                }
            }

            if status != errSecSuccess {
                throw error(from: status)
            }
        default:
            throw error(from: status)
        }
    }

    func getPassword(for userAccount: String) async throws -> String? {

        let query = makeFindPasswordQuery(for: userAccount)

        var queryResult: AnyObject?

        let status: OSStatus = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                let status: OSStatus = withUnsafeMutablePointer(to: &queryResult) {
                    SecItemCopyMatching(query, $0)
                }
                continuation.resume(with: Result.success(status))
            }
        }

        switch status {
        case errSecSuccess:
            guard let quriedItem = queryResult as? [String: Any],
                  let passwordData = quriedItem[String(kSecValueData)] as? Data,
                  let password = String(data: passwordData, encoding: .utf8)
            else {
                throw KeyChainError.dataToStringConversionError
            }

            return password
        case errSecItemNotFound:
            return nil
        default:
            throw error(from: status)
        }
    }

    func removePassword(for userAccount: String) async throws {
        var query = PasswordQuery(service: service, appGroup: appGroup).query
        query[String(kSecAttrAccount)] = userAccount

        let status = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                let status = SecItemDelete(query as CFDictionary)
                continuation.resume(with: Result.success(status))
            }
        }

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

    func removeAllPassword() async throws {
        let query = PasswordQuery(service: service, appGroup: appGroup).query

        let status = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInteractive).async {
                let status = SecItemDelete(query as CFDictionary)
                continuation.resume(with: Result.success(status))
            }
        }
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
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
