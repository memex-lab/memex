import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Background task support
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        let registry = engineBridge.pluginRegistry
        let registrar = registry.registrar(forPlugin: "MemexAppActions")!
        AppActionChannelHandler.register(with: registrar)
        ChannelRegistrar.registerAll(with: engineBridge.applicationRegistrar.messenger())
        GeneratedPluginRegistrant.register(with: registry)
    }
}
