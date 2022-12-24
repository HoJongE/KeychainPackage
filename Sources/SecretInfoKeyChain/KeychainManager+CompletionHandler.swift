//
//  KeychainManager+CompletionHandler.swift
//  KeyChainWrapper
//
//  Created by JongHo Park on 2022/12/17.
//

import Foundation

// MARK: - Completion handler extension
public extension SecretInfoKeychain {

    /// 비밀정보를 KeyChain에 저장하는 함수, 만약 이미 키값의 데이터가 존재한다면, 덮어씌운다.
    /// - Parameters:
    ///   - secretInfo: 비밀정보
    ///   - forInfoKey: 정보의 키값
    ///   - completion: 모든 작업이 완료될 시 호출되는 클로저
    /// - Note: infoKey 에 해당하는 데이터가 이미 존재하는 경우, 해당 데이터를 새로운 secretInfo로 덮어씌우므로 주의가 필요합니다.
    func saveSecretInfo(secretInfo: String, forInfoKey infoKey: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            // password 를 데이터 convert 에 실패하면... 바로 completion handler 실행
            guard let encodedPassword: Data = try? self.data(fromSecretInfo: secretInfo) else {
                completion?(KeyChainError.stringToDataConversionError)
                return
            }
            let passwordQuery: PasswordQuery = PasswordQuery(service: self.rootKey, appGroup: self.appGroup)

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

    /// 키값의 비밀정보를 가져오는 함수
    /// - Parameters:
    ///   - forInfoKey: 키값
    ///   - completion: 완료 핸들러, 만약 데이터가 존재하지 않거나, 에러가 뜬다면 String은 nil이 된다)
    /// - Note: 만약 데이터가 존재하지 않거나, 데이터를 가져오는 도중 에러가 발생할 경우 Error가 전달됩니다.
    func secretInfo(forInfoKey infoKey: String, completion: ((String? ,Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let query = self.findInfoQuery(forInfoKey: infoKey)

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
                completion?(nil, KeyChainError.dataNotExists)
            default:
                completion?(nil, self.error(from: status))
            }
        }
    }

    /// 비밀정보를 삭제하는 함수
    /// 키값의 데이터가 없거나 성공적으로 삭제한 경우 Error가 nil인 상태로 클로저가 호출됨
    /// - Parameters:
    ///   - forInfoKey: 키값
    ///   - completion: 완료 핸들러
    /// - Note: 키값의 데이터가 원래 존재하지 않아도, 이벤트가 성공적으로 종료됩니다.
    func removeSecretInfo(forInfoKey infoKey: String, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var query = PasswordQuery(service: rootKey, appGroup: appGroup).query
            query[String(kSecAttrAccount)] = infoKey
            let status = SecItemDelete(query as CFDictionary)

            guard status == errSecSuccess || status == errSecItemNotFound else {
                completion?(error(from: status))
                return
            }
            completion?(nil)
        }
    }

    /// service 키체인 내의 저장된 데이터를 모두 삭제하는 함수입니다.
    /// - Parameter completion: 작업이 완료되거나 실패하면 호출되는 클로저
    func removeAllSecretInfos(completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let query = PasswordQuery(service: rootKey, appGroup: appGroup).query
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
private extension SecretInfoKeychain {

    func error(from status: OSStatus) -> KeyChainError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return KeyChainError.unknownError(message: message)
    }

    func data(fromSecretInfo secretInfo: String) throws -> Data {
        guard let encodedPassword = secretInfo.data(using: .utf8) else {
            throw KeyChainError.stringToDataConversionError
        }

        return encodedPassword
    }

    func findInfoQuery(forInfoKey infoKey: String) -> CFDictionary {
        let passwordQuery = PasswordQuery(service: rootKey, appGroup: appGroup)
        var ret = passwordQuery.query
        ret[String(kSecMatchLimit)] = kSecMatchLimitOne
        ret[String(kSecReturnAttributes)] = kCFBooleanTrue
        ret[String(kSecReturnData)] = kCFBooleanTrue
        ret[String(kSecAttrAccount)] = infoKey

        return ret as CFDictionary
    }

}
