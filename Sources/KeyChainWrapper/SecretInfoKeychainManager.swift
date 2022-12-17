import Foundation

public struct SecretInfoKeychainManager {

    private let service: String
    private let appGroup: String?

    public init(service: String, appGroup: String? = nil) {
        self.service = service
        self.appGroup = appGroup
    }

}

// MARK: - Completion handler extension
public extension SecretInfoKeychainManager {
    func saveSecretInfo(_ secretInfo: String, for infoKey: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            // password 를 데이터 convert 에 실패하면... 바로 completion handler 실행
            guard let encodedPassword: Data = try? self.parseInfosToData(secretInfo) else {
                completion?(KeyChainError.stringToDataConversionError)
                return
            }
            let passwordQuery: PasswordQuery = PasswordQuery(service: self.service, appGroup: self.appGroup)

            var query = passwordQuery.query
            query[String(kSecAttrAccount)] = infoKey
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

    func getSecretInfo(for infoKey: String, completion: ((String? ,Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            let query = self.makeFindInfoQuery(for: infoKey)

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

    func removeSecretInfo(for infoKey: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            var query = PasswordQuery(service: service, appGroup: appGroup).query
            query[String(kSecAttrAccount)] = infoKey
            let status = SecItemDelete(query as CFDictionary)

            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(error(from: status))
                return
            }
            completion?(nil)
        }
    }

    func removeAllInfos(completion: ((Error?) -> Void)? = nil) {
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
private extension SecretInfoKeychainManager {

    func error(from status: OSStatus) -> KeyChainError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return KeyChainError.unknownError(message: message)
    }

    func parseInfosToData(_ password: String) throws -> Data {
        guard let encodedPassword = password.data(using: .utf8) else {
            throw KeyChainError.stringToDataConversionError
        }

        return encodedPassword
    }

    func makeFindInfoQuery(for userAccount: String) -> CFDictionary {
        let passwordQuery = PasswordQuery(service: service, appGroup: appGroup)
        var ret = passwordQuery.query
        ret[String(kSecMatchLimit)] = kSecMatchLimitOne
        ret[String(kSecReturnAttributes)] = kCFBooleanTrue
        ret[String(kSecReturnData)] = kCFBooleanTrue
        ret[String(kSecAttrAccount)] = userAccount

        return ret as CFDictionary
    }

}
