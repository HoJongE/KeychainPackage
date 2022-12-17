import Foundation

public struct SecretInfoKeychainManager {

    let service: String
    let appGroup: String?

    public init(service: String, appGroup: String? = nil) {
        self.service = service
        self.appGroup = appGroup
    }

}
