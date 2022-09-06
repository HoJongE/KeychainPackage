import XCTest
@testable import KeyChainWrapper

final class PasswordKeychainTests: XCTestCase {

    private var passwordKeychainManager: PasswordKeychainManager!
    private let testService: String = "TestService"
    private let testAccount: String = "TestAccount"
    private let testPassword: String = "TestPassword"

    override func setUp() async throws {
        try await super.setUp()
        passwordKeychainManager = .init(PasswordKeychainManager(service: testService))
    }

    override func tearDown() async throws {
        try await passwordKeychainManager.removeAllPassword()
        passwordKeychainManager = nil
        try await super.tearDown()
    }

    func testSaveAndGetPassword() async {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            let password = try await passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertEqual(password, testPassword)
        } catch {
            XCTFail("Saving Password failed, \(error.localizedDescription)")
        }
    }

    func testUpdatePassword() async {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try await passwordKeychainManager
                .savePassword(testPassword + "2", for: testAccount)

            let password = try await passwordKeychainManager.getPassword(for: testAccount)

            XCTAssertEqual(password, testPassword + "2")
            XCTAssertNotEqual(password, testPassword)
        } catch {
            XCTFail("Update Password Failed with \(error.localizedDescription)")
        }
    }

    func testRemovePassword() async {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try await passwordKeychainManager.removePassword(for: testAccount)

            let password = try await passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertNil(password)
        } catch {
            XCTFail("Remove Password Failed with \(error.localizedDescription)")
        }
    }

    func testRemoveAllPassword() async {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try await passwordKeychainManager.removeAllPassword()

            let password = try await passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertNil(password)
        } catch {
            XCTFail("Remove all passwords failed with \(error.localizedDescription)")
        }
    }

    func testSaveAndGetPasswordCompletionHandler() {
        // given
        let promise = expectation(description: "Test and save password success!")
        var password: String?
        // when
        passwordKeychainManager.savePassword(testPassword, for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getPassword(for: self.testAccount) { pw, error in
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
        passwordKeychainManager.savePassword(testPassword, for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            self.passwordKeychainManager.savePassword(testPassword + "2", for: testAccount) { [self] error in
                guard error == nil else {
                    promise.fulfill()
                    return
                }
                self.passwordKeychainManager.getPassword(for: self.testAccount) { pw, error in
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
        try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
        let pw: String? = try await passwordKeychainManager.getPassword(for: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removePassword(for: testAccount) { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getPassword(for: testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertNil(password)
    }

    func testRemoveAllPasswordCompletionHandler() async throws {
        // given
        let promise = expectation(description: "Remove password success!")
        var password: String?
        // when
        try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
        let pw: String? = try await passwordKeychainManager.getPassword(for: testAccount)
        XCTAssertEqual(testPassword, pw)
        passwordKeychainManager.removeAllPassword { [self] error in
            guard error == nil else {
                promise.fulfill()
                return
            }
            passwordKeychainManager.getPassword(for: testAccount) { pw, error in
                password = pw
                promise.fulfill()
            }
        }

        // then
        wait(for: [promise], timeout: 1)
        XCTAssertNil(password)
    }
}
