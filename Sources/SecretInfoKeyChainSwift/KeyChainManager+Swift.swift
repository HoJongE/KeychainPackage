//
//  KeychainManager+Concurrency.swift
//  KeyChainWrapper
//
//  Created by JongHo Park on 2022/12/17.
//

import Foundation

import SecretInfoKeyChain

// MARK: - Public Interface
// MARK: - Async/Await extension
public extension SecretInfoKeychain {

    /// 비밀정보를 KeyChain에 저장하는 함수, 만약 이미 키값의 데이터가 존재한다면, 덮어씌운다.
    /// - Parameters:
    ///   - secretInfo: 비밀정보
    ///   - infoKey: 비밀정보가 저장될 키 값
    /// - Note: infoKey 에 해당하는 데이터가 이미 존재하는 경우, 해당 데이터를 새로운 secretInfo로 덮어씌우므로 주의가 필요합니다.
    func saveSecretInfo(secretInfo: String, forInfoKey infoKey: String) async throws {
        try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    /// 키값의 비밀정보를 가져오는 함수
    /// - Parameter infoKey: 키값
    /// - Returns: 비밀정보
    /// - Note: 비밀정보가 없는 경우도 Error가 반환됩니다.
    func secretInfo(forInfoKey infoKey: String) async throws -> String {
        let password: String = try await withCheckedThrowingContinuation { [self] continuation in
            secretInfo(forInfoKey: infoKey) { password, error in
                guard error == nil, let password else {
                    continuation.resume(throwing: error!)
                    return
                }
                continuation.resume(returning: password)
            }
        }
        return password
    }

    /// 키값의 비밀정보를 삭제하는 함수
    /// 키값의 비밀정보가 없거나, 삭제에 성공한 경우 정상적으로 종료됩니다.
    /// - Parameter infoKey: 키값
    func removeSecretInfo(forInfoKey infoKey: String) async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removeSecretInfo(forInfoKey: infoKey) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    /// rootKey의 모든 비밀정보를 삭제하는 함수
    func removeAllSecretInfos() async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removeAllSecretInfos { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
