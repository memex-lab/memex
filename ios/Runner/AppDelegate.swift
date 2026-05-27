import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
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
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "memex", url.host == "agent_activity" {
            AgentBackgroundChannelHandler.handleOpenAgentActivityIntent()
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
