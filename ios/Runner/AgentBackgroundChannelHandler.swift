import Flutter
import UIKit

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

#if canImport(ActivityKit)
import ActivityKit
#endif

class AgentBackgroundChannelHandler {
    private static let channelName = "com.memexlab.memex/agent_background"
    private static var channel: FlutterMethodChannel?
    private static var pendingOpenAgentActivity = false
    private static var latestStatus: [String: Any]?

    #if canImport(BackgroundTasks)
    private static var continuedProcessingTask: Any?
    private static var continuedProcessingRequestIdentifier: String?
    private static var didRegisterContinuedProcessingTask = false
    #endif

    static func register(with messenger: FlutterBinaryMessenger) {
        let methodChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: messenger
        )
        channel = methodChannel
        methodChannel.setMethodCallHandler { call, result in
            switch call.method {
            case "updateAgentStatus":
                guard let status = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "bad_args", message: "Missing status", details: nil))
                    return
                }
                update(status: status, terminal: false)
                result(nil)
            case "finishAgentStatus":
                guard let status = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "bad_args", message: "Missing status", details: nil))
                    return
                }
                update(status: status, terminal: true)
                result(nil)
            case "stopAgentStatus":
                stopContinuedProcessingTask()
                endLiveActivity()
                result(nil)
            case "consumeInitialAgentAction":
                if pendingOpenAgentActivity {
                    pendingOpenAgentActivity = false
                    result("agent_activity")
                } else {
                    result(nil)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func update(status: [String: Any], terminal: Bool) {
        latestStatus = status
        updateContinuedProcessingTask(status: status, terminal: terminal)
        updateLiveActivity(status: status, terminal: terminal)
    }

    static func handleOpenAgentActivityIntent() {
        if let channel {
            channel.invokeMethod("openAgentActivity", arguments: nil)
        } else {
            pendingOpenAgentActivity = true
        }
    }

    static func queueOpenAgentActivityIntent() {
        pendingOpenAgentActivity = true
    }

    private static func updateLiveActivity(status: [String: Any], terminal: Bool) {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            let state = AgentProcessingAttributes.ContentState(
                runState: status["state"] as? String ?? "active",
                stage: status["stage"] as? String ?? "Processing",
                detail: status["detail"] as? String ?? "",
                remainingTasks: status["remainingTasks"] as? Int ?? 0,
                updatedAt: Date()
            )
            Task {
                let activities = Activity<AgentProcessingAttributes>.activities
                if let activity = activities.first {
                    if #available(iOS 16.2, *) {
                        await activity.update(ActivityContent(state: state, staleDate: nil))
                        if terminal {
                            await activity.end(
                                ActivityContent(state: state, staleDate: nil),
                                dismissalPolicy: .after(Date(timeIntervalSinceNow: 5))
                            )
                        }
                    } else {
                        await activity.update(using: state)
                        if terminal {
                            await activity.end(using: state, dismissalPolicy: .after(Date(timeIntervalSinceNow: 5)))
                        }
                    }
                } else if !terminal {
                    do {
                        if #available(iOS 16.2, *) {
                            _ = try Activity<AgentProcessingAttributes>.request(
                                attributes: AgentProcessingAttributes(name: "Memex"),
                                content: ActivityContent(state: state, staleDate: nil),
                                pushType: nil
                            )
                        } else {
                            _ = try Activity<AgentProcessingAttributes>.request(
                                attributes: AgentProcessingAttributes(name: "Memex"),
                                contentState: state,
                                pushType: nil
                            )
                        }
                    } catch {
                        NSLog("Agent Live Activity request failed: \(error)")
                    }
                }
            }
        }
        #endif
    }

    private static func endLiveActivity() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            Task {
                for activity in Activity<AgentProcessingAttributes>.activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
        #endif
    }

    private static func stopContinuedProcessingTask() {
        #if canImport(BackgroundTasks)
        if #available(iOS 26.0, *) {
            cancelContinuedProcessingRequest()
            completeContinuedProcessingTask(success: true)
        }
        #endif
    }

    static func registerContinuedProcessingTaskHandler() {
        #if canImport(BackgroundTasks)
        if #available(iOS 26.0, *) {
            guard !didRegisterContinuedProcessingTask else { return }
            guard let identifier = continuedProcessingWildcardIdentifier() else { return }

            didRegisterContinuedProcessingTask = BGTaskScheduler.shared.register(
                forTaskWithIdentifier: identifier,
                using: nil
            ) { task in
                handleContinuedProcessingLaunch(task)
            }

            if !didRegisterContinuedProcessingTask {
                NSLog("Agent continued processing task registration failed")
            }
        }
        #endif
    }

    private static func updateContinuedProcessingTask(status: [String: Any], terminal: Bool) {
        #if canImport(BackgroundTasks)
        if #available(iOS 26.0, *) {
            let state = status["state"] as? String ?? "active"
            if state == "idle" {
                cancelContinuedProcessingRequest()
                completeContinuedProcessingTask(success: true)
                return
            }

            if state == "active" {
                submitContinuedProcessingRequestIfNeeded(status: status)
                updateActiveContinuedProcessingTask(status: status)
                return
            }

            updateActiveContinuedProcessingTask(status: status)
            completeContinuedProcessingTask(success: state == "completed")
        }
        #endif
    }

    #if canImport(BackgroundTasks)
    @available(iOS 26.0, *)
    private static func handleContinuedProcessingLaunch(_ task: BGTask) {
        guard let task = task as? BGContinuedProcessingTask else {
            task.setTaskCompleted(success: false)
            return
        }

        continuedProcessingTask = task
        if let status = latestStatus {
            updateActiveContinuedProcessingTask(status: status)
        } else {
            task.updateTitle("Memex is processing", subtitle: "Finishing agent tasks")
            task.progress.totalUnitCount = 100
            task.progress.completedUnitCount = 5
        }

        task.expirationHandler = {
            completeContinuedProcessingTask(success: false)
        }
    }

    @available(iOS 26.0, *)
    private static func submitContinuedProcessingRequestIfNeeded(status: [String: Any]) {
        guard didRegisterContinuedProcessingTask else { return }
        guard continuedProcessingTask == nil else { return }
        guard continuedProcessingRequestIdentifier == nil else { return }
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }

        let identifier = "\(bundleIdentifier).agentQueue.\(UUID().uuidString)"
        let labels = continuedProcessingLabels(for: status)
        let request = BGContinuedProcessingTaskRequest(
            identifier: identifier,
            title: labels.title,
            subtitle: labels.subtitle
        )
        request.strategy = .queue
        request.requiredResources = []

        do {
            try BGTaskScheduler.shared.submit(request)
            continuedProcessingRequestIdentifier = identifier
        } catch {
            NSLog("Agent continued processing request failed: \(error)")
        }
    }

    @available(iOS 26.0, *)
    private static func updateActiveContinuedProcessingTask(status: [String: Any]) {
        guard let task = continuedProcessingTask as? BGContinuedProcessingTask else { return }
        let labels = continuedProcessingLabels(for: status)
        task.updateTitle(labels.title, subtitle: labels.subtitle)
        task.progress.totalUnitCount = 100
        task.progress.completedUnitCount = continuedProcessingProgress(for: status)
    }

    @available(iOS 26.0, *)
    private static func completeContinuedProcessingTask(success: Bool) {
        guard let task = continuedProcessingTask as? BGContinuedProcessingTask else { return }
        task.progress.completedUnitCount = 100
        task.setTaskCompleted(success: success)
        continuedProcessingTask = nil
        continuedProcessingRequestIdentifier = nil
    }

    @available(iOS 26.0, *)
    private static func cancelContinuedProcessingRequest() {
        guard let identifier = continuedProcessingRequestIdentifier else { return }
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
        continuedProcessingRequestIdentifier = nil
    }

    @available(iOS 26.0, *)
    private static func continuedProcessingWildcardIdentifier() -> String? {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }
        return "\(bundleIdentifier).agentQueue.*"
    }

    private static func continuedProcessingLabels(for status: [String: Any]) -> (title: String, subtitle: String) {
        let title = status["stage"] as? String ?? "Memex is processing"
        if let detail = status["detail"] as? String, !detail.isEmpty {
            return (title, detail)
        }

        let remaining = status["remainingTasks"] as? Int ?? 0
        if remaining > 0 {
            return (title, "\(remaining) agent tasks remaining")
        }
        return (title, "Finishing agent tasks")
    }

    private static func continuedProcessingProgress(for status: [String: Any]) -> Int64 {
        let state = status["state"] as? String ?? "active"
        guard state == "active" else { return 100 }

        let remaining = status["remainingTasks"] as? Int ?? 0
        if remaining <= 0 { return 95 }
        return max(5, min(90, 100 - Int64(remaining * 15)))
    }
    #endif
}
