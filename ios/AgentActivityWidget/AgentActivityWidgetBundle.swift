import SwiftUI
import WidgetKit

@main
struct AgentActivityWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        if #available(iOSApplicationExtension 16.1, *) {
            AgentActivityLiveActivity()
        }
    }
}
