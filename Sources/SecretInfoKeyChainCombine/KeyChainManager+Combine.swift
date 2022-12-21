//
//  KeyChainManager+Combine.swift
//  KeyChainWrapper
//
//  Created by JongHo Park on 2022/12/17.
//

import Combine
import Foundation

import SecretInfoKeyChain

// MARK: - Combine Extension
public extension SecretInfoKeychain {

    func saveSecretInfo(_ secretInfo: String, for infoKey: String) -> AnyPublisher<Void, Error> { 
        Future { promise in
            saveSecretInfo(secretInfo, for: infoKey) { error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(()))
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func getSecretInfo(for infoKey: String) -> AnyPublisher<String, Error> {
        Future { promise in
            getSecretInfo(for: infoKey) { value, error in
                guard error == nil, let value else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(value))
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func removeSecretInfo(for infoKey: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            removeSecretInfo(for: infoKey) { error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(()))
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func removeAllInfos() -> AnyPublisher<Void, Error> {
        Future { promise in
            removeAllInfos { error in
                guard error == nil else {
                    promise(.failure(error!))
                    return
                }
                promise(.success(()))
            }
        }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

}
