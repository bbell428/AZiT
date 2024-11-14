//
//  AzitWidgetLiveActivity.swift
//  AzitWidget
//
//  Created by Hyunwoo Shin on 11/14/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AzitWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AzitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AzitWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AzitWidgetAttributes {
    fileprivate static var preview: AzitWidgetAttributes {
        AzitWidgetAttributes(name: "World")
    }
}

extension AzitWidgetAttributes.ContentState {
    fileprivate static var smiley: AzitWidgetAttributes.ContentState {
        AzitWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AzitWidgetAttributes.ContentState {
         AzitWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AzitWidgetAttributes.preview) {
   AzitWidgetLiveActivity()
} contentStates: {
    AzitWidgetAttributes.ContentState.smiley
    AzitWidgetAttributes.ContentState.starEyes
}
