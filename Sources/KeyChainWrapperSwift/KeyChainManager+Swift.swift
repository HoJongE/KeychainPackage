//
//  KeychainManager+Concurrency.swift
//  KeyChainWrapper
//
//  Created by JongHo Park on 2022/12/17.
//

import Foundation

import KeyChainWrapper

// MARK: - Public Interface
// MARK: - Async/Await extension
public extension SecretInfoKeychainManager {

    func saveSecretInfo(_ secretInfo: String, for infoKey: String) async throws {
        try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            saveSecretInfo(secretInfo, for: infoKey) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    func getSecretInfo(for infoKey: String) async throws -> String {
        let password: String = try await withCheckedThrowingContinuation { [self] continuation in
            getSecretInfo(for: infoKey) { password, error in
                guard error == nil, let password else {
                    continuation.resume(throwing: error!)
                    return
                }
                continuation.resume(returning: password)
            }
        }
        return password
    }

    func removeSecretInfo(for infoKey: String) async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removeSecretInfo(for: infoKey) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    func removeAllInfos() async throws {
        _ = try await withCheckedThrowingContinuation { [self] (continuation: CheckedContinuation<Void, Error>) in
            removeAllInfos { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
