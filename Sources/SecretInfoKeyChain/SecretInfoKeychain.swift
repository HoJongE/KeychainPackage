import Foundation

/// 비밀정보를 관리하도록 도와주는 객체입니다.
public struct SecretInfoKeychain {

    let rootKey: String
    let appGroup: String?

    /// Keychain의 최상위 키값, 그리고 appGroup을 지정함으로써 인스턴스를 생성할 수 있습니다.
    /// - Parameters:
    ///   - service: Keychain의 최상위 키값 (보통 번들 아이디를 추천합니다.)
    ///   - appGroup: AppGroup을 지정해주면, 그룹 내의 애플리케이션들끼리 데이터가 공유됩니다.
    public init(
        rootKey: String,
        appGroup: String? = nil
    ) {
        self.rootKey = rootKey
        self.appGroup = appGroup
    }

}
