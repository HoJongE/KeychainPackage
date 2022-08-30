import XCTest
@testable import KeyChainWrapper

final class PasswordKeychainTests: XCTestCase {

    private var passwordKeychainManager: PasswordKeychainManager!
    private let testService: String = "TestService"
    private let testAccount: String = "TestAccount"
    private let testPassword: String = "TestPassword"

    override func setUpWithError() throws {
        passwordKeychainManager = .init(PasswordKeychainManager(service: testService))
        try super.setUpWithError()
    }

    override func tearDown() async throws {
        try await passwordKeychainManager.removeAllPassword()
        passwordKeychainManager = nil
        try await super.tearDown()
    }

    func testSaveAndGetPassword() async throws {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            let password = try await passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertEqual(password, testPassword)
        } catch {
            XCTFail("Saving Password failed, \(error.localizedDescription)")
        }
    }

    func testUpdatePassword() async throws {
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

    func testRemovePassword() async throws {
        do {
            try await passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try await passwordKeychainManager.removePassword(for: testAccount)

            let password = try await passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertNil(password)
        } catch {
            XCTFail("Remove Password Failed with \(error.localizedDescription)")
        }
    }
}
