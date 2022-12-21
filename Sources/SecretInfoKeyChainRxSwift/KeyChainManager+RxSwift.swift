//
//  File.swift
//  
//
//  Created by JongHo Park on 2022/12/18.
//

import Foundation

import SecretInfoKeyChain
import RxSwift

// MARK: - Rx Extension
public extension SecretInfoKeychain {

    func saveSecretInfo(_ secretInfo: String, for infoKey: String) -> Single<Void> {
        Single.create { single in
            saveSecretInfo(secretInfo, for: infoKey) { error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                single(.success(()))
            }
            return Disposables.create()
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }

    func getSecretInfo(for infoKey: String) -> Single<String> {
        Single.create { single in
            getSecretInfo(for: infoKey) { value, error in
                guard error == nil, let value else {
                    single(.error(error!))
                    return
                }
                single(.success(value))
            }
            return Disposables.create()
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }

    func removeSecretInfo(for infoKey: String) -> Single<Void> {
        Single.create { single in
            removeSecretInfo(for: infoKey) { error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                single(.success(()))
            }
            return Disposables.create()
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }

    func removeAllInfos() -> Single<Void> {
        Single.create { single in
            removeAllInfos { error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                single(.success(()))
            }
            return Disposables.create()
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }

}
