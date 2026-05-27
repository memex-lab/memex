import Flutter

/// Central registration point for all MethodChannel handlers.
///
/// Pattern follows Flutter first-party plugins (camera, video_player, etc.):
/// each channel has its own handler class that encapsulates parameter parsing
/// and result dispatch, while heavy business logic lives in dedicated helpers.
///
/// To add a new channel:
/// 1. Create a `*ChannelHandler.swift` file with a static `register(with:)` method
/// 2. Call it here
class ChannelRegistrar {
    static func registerAll(with messenger: FlutterBinaryMessenger) {
        WebViewChannelHandler.register(with: messenger)
        StorageChannelHandler.register(with: messenger)
        SystemActionsChannelHandler.register(with: messenger)
        AudioConverterChannelHandler.register(with: messenger)
        AgentBackgroundChannelHandler.register(with: messenger)
    }
}
