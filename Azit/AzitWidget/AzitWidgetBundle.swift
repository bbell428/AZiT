//
//  AzitWidgetBundle.swift
//  AzitWidget
//
//  Created by Hyunwoo Shin on 11/14/24.
//

import WidgetKit
import SwiftUI
import FirebaseCore

@main
struct AzitWidgetBundle: WidgetBundle {
    init() {
        FirebaseApp.configure()
    }
    
    @WidgetBundleBuilder
    private var iOSAllWidgets: some Widget {
        AzitWidget()
    }
    
    @available(iOSApplicationExtension 17.0, iOS 17.0, *)
    @WidgetBundleBuilder
    private var iOS17Widgets: some Widget {
        AzitWidget()
        AzitWidgetLiveActivity()
    }
    
    @available(iOSApplicationExtension 18.0, iOS 18.0, *)
        @WidgetBundleBuilder
        private var iOS18Widgets: some Widget {
            AzitWidget()
            AzitWidgetControl()
            AzitWidgetLiveActivity()
        }
    
    var body: some Widget {
        if #available(iOSApplicationExtension 18.0, *) {
            return iOS18Widgets
        } else {
            return getWidgetsThatAreNOTControlWidgets()
        }
    }
    
    private func getWidgetsThatAreNOTControlWidgets() -> some Widget {
        if #available(iOSApplicationExtension 17.0, *) {
            return iOS17Widgets
        } else {
            return iOSAllWidgets
        }
    }
}
