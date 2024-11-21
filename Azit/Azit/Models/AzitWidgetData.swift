//
//  AzitWidgetData.swift
//  Azit
//
//  Created by Hyunwoo Shin on 11/19/24.
//

import SwiftUI

class AzitWidgetData: ObservableObject {
    @Published var recentStory: Story?
    @Published var userInfo: UserInfo?
    @Published var image: UIImage?
}
