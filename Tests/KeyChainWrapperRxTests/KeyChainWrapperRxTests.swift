//
//  KeyChainWrapperRxTests.swift
//  
//
//  Created by JongHo Park on 2022/12/18.
//

import XCTest
@testable import SecretInfoKeyChain
@testable import SecretInfoKeyChainRxSwift

import RxSwift
import RxBlocking
import RxTest

final class KeyChainWrapperRxTests: XCTestCase {

    private var disposeBag: DisposeBag!
    private var keychainManager: SecretInfoKeychain!
    private let secretInfo: String = "Better than this"
    private let infoKey: String = "InfoKey"

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = .init()
        keychainManager = .init(rootKey: "Test")
    }

    override func tearDownWithError() throws {
        _ = try keychainManager.removeAllSecretInfos().toBlocking(timeout: 2).last()
        disposeBag = nil
        keychainManager = nil
        try super.tearDownWithError()
    }

    func test_비밀정보를_잘_저장하고_잘_가져오는지() throws {
        _ = try keychainManager
            .saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey)
            .toBlocking()
            .first()

        guard let valueFromKeyChain = try keychainManager
            .secretInfo(forInfoKey: infoKey)
            .toBlocking()
            .first() else {
            XCTFail(#function)
            return
        }

        XCTAssertEqual(valueFromKeyChain, secretInfo)
    }

    func test_비밀정보가_없으면_못가져오는지() {
        do {
            _ = try keychainManager
                .secretInfo(forInfoKey: infoKey)
                .toBlocking()
                .first()
            XCTFail(#function)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {
            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func test_비밀정보를_잘_삭제하는지() {
        do {
            _ = try keychainManager
                .saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey)
                .toBlocking()
                .first()
            _ = try keychainManager
                .removeSecretInfo(forInfoKey: infoKey)
                .toBlocking()
                .first()
            _ = try keychainManager
                .secretInfo(forInfoKey: infoKey)
                .toBlocking()
                .first()
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {
            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }
}
