import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let shouldOpenAgentActivity = (launchOptions?[.url] as? URL)
            .map { self.isAgentActivityURL($0) } ?? false
        let controller = window?.rootViewController as! FlutterViewController

        // Background task support
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "agent_queue_drain")
        AgentBackgroundChannelHandler.registerContinuedProcessingTaskHandler()

        // Register all MethodChannel handlers
        ChannelRegistrar.registerAll(with: controller.binaryMessenger)

        GeneratedPluginRegistrant.register(with: self)
        if shouldOpenAgentActivity {
            AgentBackgroundChannelHandler.queueOpenAgentActivityIntent()
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if isAgentActivityURL(url) {
            AgentBackgroundChannelHandler.handleOpenAgentActivityIntent()
            return true
        }
        return super.application(app, open: url, options: options)
    }

    private func isAgentActivityURL(_ url: URL) -> Bool {
        url.scheme == "memex" && url.host == "agent_activity"
    }
}
