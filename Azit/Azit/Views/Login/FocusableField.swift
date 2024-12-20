//
//  FocusableField.swift
//  Azit
//
//  Created by 김종혁 on 12/20/24.
//

// 로그인 과정에서 포커스를 지정하기 위해 사용
enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
    case nickname
}
