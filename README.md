# 📱 AZiT

<img src="https://github.com/user-attachments/assets/6a658e08-fc3e-476b-9431-7dd4584597e2" alt="배너" width="100%"/>
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
| <img src="https://github.com/user-attachments/assets/2dc5f59b-dbf9-4a3b-bcba-e39eb39c09e9" alt="홍지수" width="150"> | <img src="https://github.com/user-attachments/assets/8595069a-e433-4d7a-8902-7df506f99228" alt="김종혁" width="150"> | <img src="https://github.com/user-attachments/assets/0d97371c-e8eb-47d5-9dc8-f23dead9e067" alt="박준영" width="150"> | <img src="https://github.com/user-attachments/assets/83e8e853-67f4-4ff5-9f68-1486e143b7ee" alt="신현우" width="150"> |
| PM | iOS | iOS | iOS |
| [GitHub](https://github.com/jisooohh) | [GitHub](https://github.com/bbell428) | [GitHub](https://github.com/PlayTheApp) | [GitHub](https://github.com/show2633) |

<br/>
<br/>

# 👤User Flow
<img src="https://github.com/user-attachments/assets/54e2d3a1-f5f4-43a7-979b-3b110024d959" alt="배너" width="100%"/>

# 🚀 주요 기능
- 🗂️ **기능 1**: [기능에 대한 간단 설명]
- 🛠️ **기능 2**: [기능에 대한 간단 설명]
- 🌟 **기능 3**: [기능에 대한 간단 설명]

<br/>
<br/>

# ⚙️ Setting
- **Xcode 버전**: Xcode 16.0
- **iOS 버전**: iOS 17.0

<br/>
<br/>

# Technology Stack
## Language
| Swift | SwiftUI |
|:------:|:------:|
| <img src="https://developer.apple.com/swift/images/swift-logo.svg" alt="Swift" width="100"> | <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" alt="SwiftUI" width="100"> | 

<br/>

## Backen
| Firebase | Koyeb |
|:------:|:------:|
| <img src="https://firebase.google.com/static/images/brand-guidelines/logo-vertical.png?hl=ko" alt="Firebase" width="100"> | <img src="https://github.com/user-attachments/assets/d8a10ada-a8c7-4a76-9154-1dc308309c15" alt="Koyeb" width="100"> | 
| 11.4.0 | v5.3.0 |

<br/>

## Cooperation
| Git | Discord | Notion | Figma |
|:------:|:------:|:------:|:------:|
| <img src="https://github.com/user-attachments/assets/03b7d917-65bb-4027-b1a2-630f4050f1a4" alt="git" width="100"> | <img src="https://github.com/user-attachments/assets/b256c308-3e77-4e8c-9101-53f4bf6dc8f2" alt="Discord" width="100"> |<img src="https://github.com/user-attachments/assets/16703970-7713-49dd-a8fa-28301b884315" width="100"> | <img src="https://github.com/user-attachments/assets/c96f0599-089f-4b91-ab30-4efd1d7da2f4" alt="Notion" width="100"> |

<br/>

# 📂 Project Structure
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

# 📂 Model
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
