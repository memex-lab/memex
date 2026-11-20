import Flutter

/// Handles Memex app-action deep links such as memex://quick_note.
class AppActionChannelHandler: NSObject, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
    private static let shared = AppActionChannelHandler()
    private static let memexScheme = "memex"

    private var pendingLink: String?
    private var eventSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addSceneDelegate(shared)
        let messenger = registrar.messenger()
        let methodChannel = FlutterMethodChannel(
            name: "com.memexlab.memex/app_actions",
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler { call, result in
            switch call.method {
            case "getInitialLink":
                result(shared.pendingLink)
            case "clearInitialLink":
                shared.pendingLink = nil
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let eventChannel = FlutterEventChannel(
            name: "com.memexlab.memex/app_action_events",
            binaryMessenger: messenger
        )
        eventChannel.setStreamHandler(shared)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions?) -> Bool {
        connectionOptions?.urlContexts.contains { Self.handleURL($0.url) } ?? false
    }

    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) -> Bool {
        contexts.contains { Self.handleURL($0.url) }
    }

    static func handleURL(_ url: URL?) -> Bool {
        guard let url = url,
              url.scheme?.lowercased() == memexScheme else {
            return false
        }

        let link = url.absoluteString
        DispatchQueue.main.async {
            if let eventSink = shared.eventSink {
                eventSink(link)
                shared.pendingLink = nil
            } else {
                shared.pendingLink = link
            }
        }
        return true
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if let pendingLink = pendingLink {
            events(pendingLink)
            self.pendingLink = nil
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
