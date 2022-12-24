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

    /// 비밀정보를 KeyChain에 저장하는 함수, 만약 이미 키값의 데이터가 존재한다면, 덮어씌운다.
    /// - Parameters:
    ///   - secretInfo: 비밀정보
    ///   - infoKey: 비밀정보가 저장될 키 값
    /// - Returns: 발행 이벤트
    /// - Note: infoKey 에 해당하는 데이터가 이미 존재하는 경우, 해당 데이터를 새로운 secretInfo로 덮어씌우므로 주의가 필요합니다.
    func saveSecretInfo(secretInfo: String, forInfoKey infoKey: String) -> AnyPublisher<Void, Error> { 
        Future { promise in
            saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey) { error in
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

    /// 키값의 비밀정보를 가져오는 함수
    /// - Parameter infoKey: 키값
    /// - Returns: 비밀정보 발행
    /// - Note: 비밀정보가 없는 경우도 Error가 반환됩니다.
    func secretInfo(forInfoKey infoKey: String) -> AnyPublisher<String, Error> {
        Future { promise in
            secretInfo(forInfoKey: infoKey) { value, error in
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

    /// 키값의 비밀정보를 삭제하는 함수
    /// 키값의 비밀정보가 없거나, 삭제에 성공한 경우 정상적으로 종료됩니다.
    /// - Parameter infoKey: 키값
    /// - Returns: 삭제 이벤트
    func removeSecretInfo(forInfoKey infoKey: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            removeSecretInfo(forInfoKey: infoKey) { error in
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

    /// rootKey의 모든 비밀정보를 삭제하는 함수
    /// - Returns: 삭제 이벤트
    func removeAllSecretInfos() -> AnyPublisher<Void, Error> {
        Future { promise in
            removeAllSecretInfos { error in
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

