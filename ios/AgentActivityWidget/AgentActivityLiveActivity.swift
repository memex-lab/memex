import ActivityKit
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
struct AgentActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AgentProcessingAttributes.self) { context in
            AgentActivityLockScreenView(state: context.state)
                .activityBackgroundTint(Color.white)
                .activitySystemActionForegroundColor(Color(red: 0.31, green: 0.34, blue: 0.92))
                .widgetURL(URL(string: "memex://agent_activity"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.stage)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingTasks)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.detail)
                        .font(.caption2)
                        .lineLimit(2)
                }
            } compactLeading: {
                Image(systemName: iconName(for: context.state.runState))
            } compactTrailing: {
                Text("\(context.state.remainingTasks)")
            } minimal: {
                Image(systemName: iconName(for: context.state.runState))
            }
        }
    }

    private func iconName(for state: String) -> String {
        switch state {
        case "completed":
            return "checkmark.circle.fill"
        case "failed":
            return "exclamationmark.triangle.fill"
        default:
            return "sparkles"
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
private struct AgentActivityLockScreenView: View {
    let state: AgentProcessingAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(state.stage)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.06, green: 0.09, blue: 0.16))
                    .lineLimit(1)
                Text(state.detail)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.39, green: 0.45, blue: 0.55))
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            if state.runState == "active" {
                Text("\(state.remainingTasks)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.31, green: 0.34, blue: 0.92))
            }
        }
        .padding()
    }

    private var iconName: String {
        switch state.runState {
        case "completed":
            return "checkmark.circle.fill"
        case "failed":
            return "exclamationmark.triangle.fill"
        default:
            return "sparkles"
        }
    }

    private var iconColor: Color {
        switch state.runState {
        case "completed":
            return Color(red: 0.06, green: 0.73, blue: 0.51)
        case "failed":
            return Color(red: 0.94, green: 0.27, blue: 0.27)
        default:
            return Color(red: 0.31, green: 0.34, blue: 0.92)
        }
    }
}
