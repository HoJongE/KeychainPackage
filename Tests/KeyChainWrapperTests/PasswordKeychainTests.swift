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

    override func tearDownWithError() throws {
        try passwordKeychainManager.removeAllPassword()
        passwordKeychainManager = nil
        try super.tearDownWithError()
    }

    func testSaveAndGetPassword() throws {
        do {
            try passwordKeychainManager.savePassword(testPassword, for: testAccount)
            let password = try passwordKeychainManager.getPassword(for: testAccount)
            XCTAssertEqual(password, testPassword)
        } catch {
            XCTFail("Saving Password failed, \(error.localizedDescription)")
        }
    }

    func testUpdatePassword() throws {
        do {
            try passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try passwordKeychainManager
                .savePassword(testPassword + "2", for: testAccount)

            let password = try passwordKeychainManager.getPassword(for: testAccount)

            XCTAssertEqual(password, testPassword + "2")
            XCTAssertNotEqual(password, testPassword)
        } catch {
            XCTFail("Update Password Failed with \(error.localizedDescription)")
        }
    }

    func testRemovePassword() throws {
        do {
            try passwordKeychainManager.savePassword(testPassword, for: testAccount)
            try passwordKeychainManager.removePassword(for: testAccount)

            XCTAssertNil(try passwordKeychainManager.getPassword(for: testAccount))
        } catch {
            XCTFail("Remove Password Failed with \(error.localizedDescription)")
        }
    }
}
