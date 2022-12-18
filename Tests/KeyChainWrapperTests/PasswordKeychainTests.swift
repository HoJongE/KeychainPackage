import XCTest
@testable import KeyChainWrapper
@testable import KeyChainWrapperSwift

final class PasswordKeychainTests: XCTestCase {

    private var passwordKeychainManager: SecretInfoKeychainManager!
    private let testService: String = "TestService"
    private let testAccount: String = "TestAccount"
    private let testPassword: String = "TestPassword"

    override func setUp() async throws {
        try await super.setUp()
        passwordKeychainManager = .init(SecretInfoKeychainManager(service: testService))
    }

    override func tearDown() async throws {
        try await passwordKeychainManager.removeAllInfos()
        passwordKeychainManager = nil
        try await super.tearDown()
    }

    func testSaveAndGetPassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
            let password = try await passwordKeychainManager.getSecretInfo(for: testAccount)
            XCTAssertEqual(password, testPassword)
        } catch {
            XCTFail("Saving Password failed, \(error.localizedDescription)")
        }
    }

    func test_비밀정보가_없으면_에러가뜨는지() async {
        do {
            _ = try await passwordKeychainManager.getSecretInfo(for: testAccount)
            XCTFail(#function)
        } catch {
            if case KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func testUpdatePassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
            try await passwordKeychainManager
                .saveSecretInfo(testPassword + "2", for: testAccount)

            let password = try await passwordKeychainManager.getSecretInfo(for: testAccount)

            XCTAssertEqual(password, testPassword + "2")
            XCTAssertNotEqual(password, testPassword)
        } catch {
            XCTFail("Update Password Failed with \(error.localizedDescription)")
        }
    }

    func testRemovePassword() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
            try await passwordKeychainManager.removeSecretInfo(for: testAccount)

            _ = try await passwordKeychainManager.getSecretInfo(for: testAccount)
        } catch {
            if case KeyChainError.dataNotExists = error {

            } else {
                XCTFail(#function + "\(error.localizedDescription)")
            }
        }
    }

    func testremoveAllInfos() async {
        do {
            try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
            try await passwordKeychainManager.removeAllInfos()

            _ = try await passwordKeychainManager.getSecretInfo(for: testAccount)
        } catch {
            if case KeyChainError.dataNotExists = error {

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
        passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getSecretInfo(for: self.testAccount) { pw, error in
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
        passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            self.passwordKeychainManager.saveSecretInfo(testPassword + "2", for: testAccount) { [self] error in
                guard error == nil else {
                    promise.fulfill()
                    return
                }
                self.passwordKeychainManager.getSecretInfo(for: self.testAccount) { pw, error in
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
        try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
        let pw: String? = try await passwordKeychainManager.getSecretInfo(for: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removeSecretInfo(for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getSecretInfo(for: testAccount) { pw, error in
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
        try await passwordKeychainManager.saveSecretInfo(testPassword, for: testAccount)
        let pw: String? = try await passwordKeychainManager.getSecretInfo(for: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removeAllInfos { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getSecretInfo(for: testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertNil(password)
    }
}
