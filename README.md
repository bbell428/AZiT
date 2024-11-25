# 📱 AZiT

<img src="https://github.com/user-attachments/assets/66f4cba6-2ae7-45aa-a307-ee9a236e8f30" alt="배너" width="70%"/>
</a>

<br/>
<br/>


# 🎯ADS
> 이 앱은 [친한 친구들에게 서로 간 위치를 공유하며 일상을 공유하는 위치 기반 SNS]를 중심으로 사용자들에게 혁신적인 경험을 제공합니다.

<br/>
<br/>

# 🧑🏻‍💻Team Members (팀원 및 팀 소개)
| 홍지수 | 김종혁 | 박준영 | 신현우 |
|:------:|:------:|:------:|:------:|
| <img src="https://github.com/user-attachments/assets/1802267c-df6c-41cd-9b1d-5ca937cd198e" alt="홍지수" width="150"> | <img src="https://github.com/user-attachments/assets/eb95b9f2-8619-4de6-9b38-b427498616b8" alt="김종혁" width="150"> | <img src="https://github.com/user-attachments/assets/3b13575a-1875-4321-a83d-2f471565d094" alt="박준영" width="150"> | <img src="https://github.com/user-attachments/assets/7a04a031-af4e-4166-a30f-0a45b6101e94" alt="신현우" width="150"> |
| PM | iOS | iOS | iOS |
| [GitHub](https://github.com/jisooohh) | [GitHub](https://github.com/bbell428) | [GitHub](https://github.com/PlayTheApp) | [GitHub](https://github.com/show2633) |

<br/>
<br/>

# 👤User Flow
<img src="https://github.com/user-attachments/assets/dec98cf7-05e1-496f-9e26-6a4d6c2bc2af" alt="배너" width="100%"/>

# 🚀 주요 기능
- 🗂️ **기능 1**: [기능에 대한 간단 설명]
- 🛠️ **기능 2**: [기능에 대한 간단 설명]
- 🌟 **기능 3**: [기능에 대한 간단 설명]

<br/>
<br/>

# ⚙️ 작동 환경
- **Xcode 버전**: Xcode 16.0
- **iOS 버전**: iOS 17.0

<br/>
<br/>

# Technology Stack (기술 스택)
## Language
| Swift | SwiftUI |
|:------:|:------:|
| <img src="https://developer.apple.com/swift/images/swift-logo.svg" alt="Swift" width="100"> | <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" alt="SwiftUI" width="100"> | 

<br/>

## Backend
| Firebase | Koyeb |
|:------:|:------:|
| <img src="https://firebase.google.com/static/images/brand-guidelines/logo-vertical.png?hl=ko" alt="Firebase" width="100"> | <img src="https://github.com/user-attachments/assets/18920bf9-b5f0-4fdf-92a4-2f16d23665ac" alt="Koyeb" width="100"> | 
| 10.12.5 | 10.12.5 |

<br/>

## Cooperation
| Git | Discord | Notion | Figma |
|:------:|:------:|:------:|:------:|
| <img src="https://github.com/user-attachments/assets/bc7d7670-c448-41aa-98fd-ac61110f78ca" alt="git" width="100"> | <img src="https://github.com/user-attachments/assets/47bfea42-d3c7-46bf-82f3-7f419495a8c1" alt="git kraken" width="100"> |<img src="https://github.com/user-attachments/assets/bb3b4712-06e8-4377-8f7d-7f392ac37fb5" alt="Notion" width="100"> | <img src="https://github.com/user-attachments/assets/cf540b04-2e96-4593-9ad8-3881dc8d44fe" alt="Notion" width="100"> |

<br/>

# 📂 Project Structure (프로젝트 구조)
```plaintext
Azit/
├── Azit.xcodeproj/
│   ├── Assets.xcassets/
│   ├── Auth/
│   ├── Constants/
│   ├── Extension/
│   ├── Models/
│   ├── Preview Content/Preview Assets.xcassets/
│   ├── Stores/
│   ├── Utility/
│   ├── Views/
│   ├── Azit.entitlements
│   ├── AzitApp.swift
│   ├── Info.plist
│   ├── chars.json
│   ├── icons.json
│   └── metadata.json
├── Azit/
│   ├── assets
│   └── components
├── AzitTests/
│   └── AzitTests.swift
├── AzitUITests/
│   ├── AzitUITests.swift
│   └── AzitUITestsLaunchTests.swift
├── AzitWidget/
│   ├── Assets.xcassets/
│   ├── AzitWidget.swift
│   ├── AzitWidgetBundle.swift
│   ├── AzitWidgetControl.swift
│   ├── AzitWidgetLiveActivity.swift
│   ├── Info.plist
│   ├── chars.json
│   ├── icons.json
│   └── metadata.json
│   AzitWidgetExtension.entitlements
├── .gitignore
├── LICENS
└── README.md
```

<br/>
<br/>

# 📂 Model (파이어베이스 구조)
```plaintext
Azit
├── Chat
│   └── id
│       ├── createAt: Date
│       ├── message: String
│       ├── participants: [String] 
│       ├── sender: String 
│       ├── readBy: [String] 
│       └── Messages
│           └── id
│               ├── lastMessage: String
│               ├── lastMessageAt: Date
│               ├── participants: [String] 
│               ├── roomId: String
│               └── unreadCount: [String: Int]
├── Story
│   └── UUID
│       ├── userId: String
│       ├── likes: [String]
│       ├── date: Date
│       ├── latitude: Double
│       ├── longitude: Double
│       ├── address: String
│       ├── emoji: String
│       ├── image: String
│       ├── content: String
│       ├── publishedTargets: [String]
│       └── readUsers: [String]
└── User
    └── UserID
        ├── id: String
        ├── email: String
        ├── nickname: String
        ├── profileImageName: String
        ├── previousState: String
        ├── friends: [String]
        ├── latitude: Double
        ├── longitude: Double
        ├── blockedFriends: [String]
        └── fcmToken: String  
```

<br/>
<br/>

# 라이선스
Licensed under the [MIT](LICENSE) license.
