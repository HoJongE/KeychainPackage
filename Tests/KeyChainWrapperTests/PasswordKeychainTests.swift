import XCTest
@testable import SecretInfoKeyChain
@testable import SecretInfoKeyChainSwift

final class PasswordKeychainTests: XCTestCase {

    private var passwordKeychainManager: SecretInfoKeychain!
    private let testService: String = "TestService"
    private let testAccount: String = "TestAccount"
    private let testPassword: String = "TestPassword"

    override func setUp() async throws {
        try await super.setUp()
        passwordKeychainManager = .init(SecretInfoKeychain(rootKey: testService))
    }

    override func tearDown() async throws {
        try await passwordKeychainManager.removeAllSecretInfos()
        passwordKeychainManager = nil
        try await super.tearDown()
    }

    func testSaveAndGetPassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
            let password = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
            XCTAssertEqual(password, testPassword)
        } catch {
            XCTFail("Saving Password failed, \(error.localizedDescription)")
        }
    }

    func test_비밀정보가_없으면_에러가뜨는지() async {
        do {
            _ = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
            XCTFail(#function)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func testUpdatePassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
            try await passwordKeychainManager
                .saveSecretInfo(secretInfo: testPassword + "2", forInfoKey: testAccount)

            let password = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)

            XCTAssertEqual(password, testPassword + "2")
            XCTAssertNotEqual(password, testPassword)
        } catch {
            XCTFail("Update Password Failed with \(error.localizedDescription)")
        }
    }

    func testRemovePassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
            try await passwordKeychainManager.removeSecretInfo(forInfoKey: testAccount)

            _ = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func testremoveAllInfos() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
            try await passwordKeychainManager.removeAllSecretInfos()

            _ = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
        } catch {
            if case SecretInfoKeychain.KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func testSaveAndGetPasswordCompletionHandler() {
        // given
        let promise = expectation(description: "Test and save password success!")
        var password: String?
        // when
        passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.secretInfo(forInfoKey: self.testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }
        // then

        wait(for: [promise], timeout: 1)
        XCTAssertEqual(password, testPassword, "Password is \(testPassword), test success")
    }

    func testUpdatePasswordCompletionHandler() {
        // given
        let promise = expectation(description: "Update password success!")
        var password: String?
        // when
        passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            self.passwordKeychainManager.saveSecretInfo(secretInfo: testPassword + "2", forInfoKey: testAccount) { [self] error in
                guard error == nil else {
                    promise.fulfill()
                    return
                }
                self.passwordKeychainManager.secretInfo(forInfoKey: self.testAccount) { pw, error in
                    password = pw
                    promise.fulfill()
                }
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertEqual(password, testPassword + "2")
    }

    func testRemovePasswordCompletionHandler() async throws {
        // given
        let promise = expectation(description: "Remove password success!")
        var password: String?
        // when
        try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
        let pw: String? = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removeSecretInfo(forInfoKey: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.secretInfo(forInfoKey: testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertNil(password)
    }

    func testremoveAllInfosCompletionHandler() async throws {
        // given
        let promise = expectation(description: "Remove password success!")
        var password: String?
        // when
        try await passwordKeychainManager.saveSecretInfo(secretInfo: testPassword, forInfoKey: testAccount)
        let pw: String? = try await passwordKeychainManager.secretInfo(forInfoKey: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removeAllSecretInfos { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.secretInfo(forInfoKey: testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertNil(password)
    }
}
