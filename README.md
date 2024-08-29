# GentooSDK
GentooSDK는 iOS 애플리케이션에 인터랙티브 AI 에이전트인 Gentoo를 통합할 수 있게 해주는 강력한 도구로서, 필수 UI 구성 요소와 기능을 제공하여 Gentoo의 기능을 모바일 앱에 원활하게 통합할 수 있도록 도와줍니다.

## Requirements

- (UIKit/AppKit) iOS 12.0+
- (SwiftUI) iOS 13.0+
- Swift 5.0+

### Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/waddle-corp/gentoo-sdk-ios.git`
- Select "Up to Next Major" with “1.0.0”

#### CocoaPods

```ruby
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'GentooSDK', :git => 'https://github.com/waddle-corp/gentoo-sdk-ios'
end
```


## Getting Started

### UIKit

#### Initializing GentooSDK in AppDelegate

GentooSDK를 사용하기 위해서는 앱이 시작될 때 SDK를 초기화해야 합니다. 이를 위해 AppDelegate의 application(_:didFinishLaunchingWithOptions:) 메서드에서 초기화를 수행할 수 있습니다.

```swift
import UIKit
import GentooSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // GentooSDK 초기화
        let config = Gentoo.Configruation(
            udid: "your-device-udid",
            authCode: "your-auth-code",
            clientId: "your-client-id"
        )
        Gentoo.initialize(with: config)

        return true
    }
}
```

#### Floating Buttons

GentooSDK는 두 가지 유형의 플로팅 버튼을 제공하여, `GentooChatViewController`를 모달로 표시하거나 네비게이션 스택에 추가할 수 있습니다.

1) Modal Presentation Floating Button

`GentooPresentationFloatingButton`은 사용자가 버튼을 탭할 때 `GentooChatViewController`를 모달로 표시하는 버튼입니다.

```swift
import GentooSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let floatingButton = GentooPresentationFloatingButton()
        floatingButton.itemId = "your-item-id"
        floatingButton.contentType = .normal
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 300),
            floatingButton.heightAnchor.constraint(equalToConstant: 54),
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}
```

2) Navigation Floating Button

`GentooNavigationFloatingButton`은 사용자가 버튼을 탭할 때 GentooChatViewController를 네비게이션 스택에 추가하는 버튼입니다.

```swift
import GentooSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let floatingButton = GentooNavigationFloatingButton()
        floatingButton.itemId = "your-item-id"
        floatingButton.contentType = .normal
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 300),
            floatingButton.heightAnchor.constraint(equalToConstant: 54),
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}
```

### SwiftUI

#### Floating Buttons

SwiftUI에서도 두 가지 유형의 플로팅 버튼을 제공합니다.

1) Modal Presentation Floating Button

`GentooPresentationFloatingButtonView`를 사용하여 버튼을 화면에 배치하고, 사용자가 버튼을 탭하면 모달로 GentooChatView를 표시하는 방식입니다.

따로 Sheet를 구현할 필요는 없으며, 버튼을 탭하면 자동으로 모달을 표시합니다.

```swift
import SwiftUI
import GentooSDK

struct ContentView: View {
    
    @State
    private var itemId: String? = "your-item-id"
    
    @State 
    private var contentType: Gentoo.ContentType = .normal
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TableView(contentType: $contentType)
                .edgesIgnoringSafeArea(.all)
            
            GentooPresentationFloatingButtonView(itemId: $itemId, contentType: $contentType)
                .padding(.trailing, 20)
                .padding(.bottom, 50)
        }
    }
}
```

2) Navigation Stack

SwiftUI에서 Floating Button을 탭했을 때 Navigation 동작을 하기 위해서 `GentooFloatingButtonView`에 action handler를 주입하고 `.navigationDestination(for:)`을 통해 직접 `GentooChatView`를 연결해야 합니다.

```swift
import SwiftUI
import GentooSDK

struct ContentView: View {
    
    enum NavigationDestination: Hashable {
        case chatView(itemId: String, contentType: Gentoo.ContentType)
    }
    
    @State
    private var itemId: String? = "your-item-id"
    
    @State 
    private var contentType: Gentoo.ContentType = .normal
    
    @State
    var path: NavigationPath = .init()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                TableView(contentType: $contentType)
                    .edgesIgnoringSafeArea(.all)

                GentooFloatingButtonView(itemId: $itemId, contentType: $contentType) {
                    guard let itemId else { return }
                    self.path.append(NavigationDestination.chatView(itemId: itemId, contentType: contentType))
                }
                .padding(.trailing, 20)
                .padding(.bottom, 50)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .chatView(let itemId, let contentType):
                    GentooChatView(itemId: itemId, contentType: contentType)
                }
            }
        }
    }
}
```

### Content Type

현재 상품과 관련된 다른 상품을 추천하고 싶다면 아래와 같이 content type을 recommendation으로 변경할 수 있습니다.

#### UIKit

```swift
gentooFloatingButtonView.setContentType(.recommendation)
```

#### SwiftUI

```swift
// body
GentooFloatingButtonView(itemId: $itemId, contentType: $contentType)

// somewhere
contentType = .recommendation
```


### License

GentooSDK is released under the MIT license. See LICENSE for details.
