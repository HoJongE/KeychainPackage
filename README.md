# KeyChainWrapper

비밀정보를 저장하는 Keychain 을 쉽게 사용하기 위해 만든 Wrapping API 입니다.

## 사용법

```swift
public struct SecretInfoKeychainManager {

    let service: String
    let appGroup: String?

    public init(service: String, appGroup: String? = nil) {
        self.service = service
        self.appGroup = appGroup
    }

}
```

1. 우선 위 SecretInfoKeychainManager의 인스턴스를 먼저 생성합니다. service의 경우 보통 번들 ID 혹은 해당 앱의 고유한 정보를 넘겨줍니다.

해당 인스턴스의 함수로 다음과 같은 기능을 제공합니다.

### Completion handler를 사용하는 API

1. 비밀정보를 저장하는 기능

```swift
func saveSecretInfo(_ secretInfo: String, for infoKey: String, completion: ((Error?) -> Void)? = nil)
```

비밀정보 (문자열 형태)와 비밀정보의 키값을 파라미터로 넘겨 키체인에 정보를 저장하는 API입니다. 비밀정보를 성공적으로 저장하거나 실패하면, completion handler가 실행됩니다.

만약 똑같은 키값을 가지는 정보를 넘겨준다면, 기존 정보를 덮어씁니다. 

2. 비밀정보를 가져오는 기능

```swift
func getSecretInfo(for infoKey: String, completion: ((String? ,Error?) -> Void)? = nil)
```

비밀정보의 키값을 주면 비밀정보를 가져오는 API입니다. 비밀정보는 String 형태로 불러옵니다.

3. 비밀정보를 삭제하는 기능

```swift
func removeSecretInfo(for infoKey: String, completion: ((Error?) -> Void)? = nil)
```

해당 키값의 비밀정보를 삭제하는 API입니다. 성공하거나 실패하면 completion handler가 실행됩니다.

4. 비밀정보를 모두 삭제하는 기능

```swift
func removeAllInfos(completion: ((Error?) -> Void)? = nil)
```

KeychainManager 인스턴스를 생성할 때 넘겨줬던 service 키체인 하위에 있는 모든 비밀정보를 제거하는 API입니다. 성공하거나 실패하면 completion handler가 실행됩니다.

### Async/Await 를 사용하는 API

위 기능 모두 Async/Await를 사용해서 사용할 수 있습니다. 
