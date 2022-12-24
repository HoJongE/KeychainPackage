//
//  KeyChainWrapperCombineTests.swift
//  KeyChainWrapperCombineTests
//
//  Created by JongHo Park on 2022/12/17.
//

import Combine
import XCTest

@testable import SecretInfoKeyChain
@testable import SecretInfoKeyChainCombine

final class KeyChainWrapperCombineTests: XCTestCase {

    private var cancelBag: Set<AnyCancellable>!
    private var keychainManager: SecretInfoKeychain!
    private let secretInfo: String = "SecretInfo"
    private let infoKey: String = "InfoKey"

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancelBag = .init()
        keychainManager = .init(rootKey: "Test")
    }

    override func tearDownWithError() throws {
        try waitPublisher(keychainManager.removeAllSecretInfos())
        try super.tearDownWithError()
    }

    func test_비밀정보를_잘_저장하고_가져오는지() throws {
        try waitPublisher(keychainManager.saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey))
        let result = try waitPublisher(keychainManager.secretInfo(forInfoKey: infoKey))

        XCTAssertEqual(result, secretInfo)
    }

    func test_비밀정보가_없으면_못가져오는지() {
        do {
            try waitPublisher(keychainManager.secretInfo(forInfoKey: infoKey))
            XCTFail(#function)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error)")
            }
        }
    }

    func test_비밀정보를_잘_삭제하는지() throws {
        try waitPublisher(keychainManager.saveSecretInfo(secretInfo: secretInfo, forInfoKey: infoKey))
        try waitPublisher(keychainManager.removeSecretInfo(forInfoKey: infoKey))

        do {
            try waitPublisher(keychainManager.secretInfo(forInfoKey: infoKey))
            XCTFail(#function)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error)")
            }
        }
    }
}

extension XCTestCase {

    @discardableResult
    func waitPublisher<T: Publisher>(
        _ publisher: T,
        _ timeout: TimeInterval = 1
    ) throws -> T.Output {

        let promise = expectation(description: "Publisher waiting")
        var error: Error?
        var ret: T.Output?

        let subscription: AnyCancellable = publisher
            .sink { completion in
                switch completion {
                case .failure(let err):
                    error = err
                case .finished:
                    break
                }
                promise.fulfill()
            } receiveValue: { output in
                ret = output
            }

        wait(for: [promise], timeout: timeout)
        subscription.cancel()

        guard error == nil, let ret else {
            throw error ?? XCTestError.init(.timeoutWhileWaiting)
        }

        return ret
    }

}
