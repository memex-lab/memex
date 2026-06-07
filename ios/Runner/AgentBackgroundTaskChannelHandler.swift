import BackgroundTasks
import Flutter
import UIKit

/// Bridges Memex's local agent queue to iOS background execution primitives.
///
/// The stable path uses BGProcessingTask and UIApplication background task
/// assertions. On iOS 26+, Continuous Background Tasks provide user-visible
/// progress for foreground-started agent work.
class AgentBackgroundTaskChannelHandler: NSObject {
    private static var sharedInstance: AgentBackgroundTaskChannelHandler?

    private let channel: FlutterMethodChannel
    private let processingIdentifier: String
    private let continuedIdentifierPattern: String
    private let continuedIdentifierPrefix: String

    private var dartReady = false
    private var pendingNativeRunPayload: [String: Any]?
    private var foregroundBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
    private var activeSnapshot: [String: Any] = [:]
    private var bgProcessingTask: BGProcessingTask?
    private var progressPulseTimer: Timer?
    private var syntheticProgress: Int64 = 1
    private var submittedContinuedIdentifier: String?
    private var processingTaskRegistered = false
    private var continuedProcessingRegistered = false
    private var registeredContinuedIdentifiers = Set<String>()

    @available(iOS 26.0, *)
    private var continuedProcessingTask: BGContinuedProcessingTask? {
        get { continuedProcessingTaskBox as? BGContinuedProcessingTask }
        set { continuedProcessingTaskBox = newValue }
    }
    private var continuedProcessingTaskBox: Any?

    static func register(with messenger: FlutterBinaryMessenger) {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.memexlab.memex"
        let instance = AgentBackgroundTaskChannelHandler(
            messenger: messenger,
            bundleId: bundleId
        )
        sharedInstance = instance
        instance.registerSchedulerHandlers()
        instance.channel.setMethodCallHandler(instance.handle)
    }

    private init(messenger: FlutterBinaryMessenger, bundleId: String) {
        channel = FlutterMethodChannel(
            name: "com.memexlab.memex/agent_background_tasks",
            binaryMessenger: messenger
        )
        processingIdentifier = "\(bundleId).agent.processing"
        continuedIdentifierPattern = "\(bundleId).agent.continued.*"
        continuedIdentifierPrefix = "\(bundleId).agent.continued"
        super.init()
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            dartReady = true
            flushPendingNativeRunIfNeeded()
            result(capabilities())
        case "setTaskActivity":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Expected task activity snapshot",
                    details: nil
                ))
                return
            }
            updateTaskActivity(args)
            result(true)
        case "completeBackgroundRun":
            let args = call.arguments as? [String: Any]
            let success = args?["success"] as? Bool ?? true
            completeBackgroundRuns(success: success)
            result(true)
        case "cancelBackgroundRun":
            cancelScheduledProcessing()
            completeBackgroundRuns(success: false)
            endForegroundBackgroundTask()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func capabilities() -> [String: Any] {
        var result: [String: Any] = [
            "processingIdentifier": processingIdentifier,
            "continuedIdentifierPattern": continuedIdentifierPattern,
            "bgProcessingAvailable": processingTaskRegistered,
            "continuedProcessingRuntimeAvailable": NSClassFromString("BGContinuedProcessingTaskRequest") != nil,
            "continuedProcessingEnabled": continuedProcessingRegistered,
        ]

        result["continuedProcessingCompileSupport"] = true
        result["continuedProcessingDynamicFallback"] = false

        return result
    }

    private func registerSchedulerHandlers() {
        let processingRegistered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingIdentifier,
            using: DispatchQueue.main
        ) { [weak self] task in
            guard let self = self, let task = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleProcessingTask(task)
        }

        if !processingRegistered {
            NSLog("Memex: failed to register BGProcessingTask handler for %@", processingIdentifier)
        }
        processingTaskRegistered = processingRegistered

        registerContinuedProcessingHandlerIfSupported()
    }

    private func handleProcessingTask(_ task: BGProcessingTask) {
        bgProcessingTask = task
        beginForegroundBackgroundTaskIfNeeded(reason: "bg_processing_launch")

        task.expirationHandler = { [weak self] in
            self?.handleExpiration(reason: "bg_processing_expired")
        }

        invokeRunPendingTasks(reason: "bg_processing_launch")
    }

    private func updateTaskActivity(_ snapshot: [String: Any]) {
        activeSnapshot = snapshot
        let hasActiveTasks = snapshot["hasActiveTasks"] as? Bool ?? false

        if hasActiveTasks {
            beginForegroundBackgroundTaskIfNeeded(reason: snapshot["reason"] as? String ?? "active_tasks")
            scheduleProcessingTask()
            submitContinuedProcessingIfSupported(snapshot: snapshot)
            updateContinuedProgress(snapshot: snapshot, completed: nil)
        } else {
            updateContinuedProgress(snapshot: snapshot, completed: 100)
            cancelScheduledProcessing()
            completeBackgroundRuns(success: true)
            endForegroundBackgroundTask()
        }
    }

    private func beginForegroundBackgroundTaskIfNeeded(reason: String) {
        guard foregroundBackgroundTaskId == .invalid else { return }

        foregroundBackgroundTaskId = UIApplication.shared.beginBackgroundTask(
            withName: "Memex Agent Tasks"
        ) { [weak self] in
            self?.handleExpiration(reason: "ui_background_task_expired")
        }

        if foregroundBackgroundTaskId == .invalid {
            NSLog("Memex: failed to begin UIApplication background task (%@)", reason)
        }
    }

    private func endForegroundBackgroundTask() {
        guard foregroundBackgroundTaskId != .invalid else { return }
        UIApplication.shared.endBackgroundTask(foregroundBackgroundTaskId)
        foregroundBackgroundTaskId = .invalid
    }

    private func scheduleProcessingTask() {
        guard processingTaskRegistered else { return }

        let request = BGProcessingTaskRequest(identifier: processingIdentifier)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Duplicate pending requests are expected while the queue stays active.
            NSLog("Memex: BGProcessingTask submit failed: %@", String(describing: error))
        }
    }

    private func cancelScheduledProcessing() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: processingIdentifier)
    }

    private func invokeRunPendingTasks(reason: String) {
        let payload: [String: Any] = [
            "reason": reason,
            "processingIdentifier": processingIdentifier,
            "continuedIdentifierPattern": continuedIdentifierPattern,
        ]

        DispatchQueue.main.async {
            if self.dartReady {
                self.channel.invokeMethod("runPendingAgentTasks", arguments: payload)
            } else {
                self.pendingNativeRunPayload = payload
            }
        }
    }

    private func flushPendingNativeRunIfNeeded() {
        guard let payload = pendingNativeRunPayload else { return }
        pendingNativeRunPayload = nil
        channel.invokeMethod("runPendingAgentTasks", arguments: payload)
    }

    private func handleExpiration(reason: String) {
        let expire = {
            self.channel.invokeMethod("backgroundTaskExpired", arguments: ["reason": reason])

            self.scheduleProcessingTask()
            self.completeBackgroundRuns(success: false)
            self.endForegroundBackgroundTask()
        }

        if Thread.isMainThread {
            expire()
        } else {
            DispatchQueue.main.async(execute: expire)
        }
    }

    private func completeBackgroundRuns(success: Bool) {
        bgProcessingTask?.setTaskCompleted(success: success)
        bgProcessingTask = nil

        completeContinuedProcessingIfSupported(success: success)
        stopProgressPulse()
    }

    private func startProgressPulse() {
        guard progressPulseTimer == nil else { return }
        syntheticProgress = max(1, syntheticProgress)
        progressPulseTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.syntheticProgress = min(95, self.syntheticProgress + 1)
            self.updateContinuedProgress(snapshot: self.activeSnapshot, completed: self.syntheticProgress)
        }
    }

    private func stopProgressPulse() {
        progressPulseTimer?.invalidate()
        progressPulseTimer = nil
        syntheticProgress = 1
    }

    private func registerContinuedProcessingHandlerIfSupported() {
        if #available(iOS 26.0, *) {
            continuedProcessingRegistered = true
        }
    }

    @available(iOS 26.0, *)
    private func handleContinuedProcessingTask(_ task: BGContinuedProcessingTask) {
        continuedProcessingTask = task
        task.progress.totalUnitCount = 100
        task.progress.completedUnitCount = max(1, syntheticProgress)

        task.expirationHandler = { [weak self] in
            self?.handleExpiration(reason: "continued_processing_expired")
        }

        startProgressPulse()
        invokeRunPendingTasks(reason: "continued_processing_launch")
    }

    private func submitContinuedProcessingIfSupported(snapshot: [String: Any]) {
        guard submittedContinuedIdentifier == nil else { return }
        guard continuedProcessingRegistered else { return }
        guard UIApplication.shared.applicationState == .active else { return }

        if #available(iOS 26.0, *) {
            let identifier = "\(continuedIdentifierPrefix).\(UUID().uuidString)"
            guard registerContinuedProcessingHandler(identifier: identifier) else {
                return
            }
            let request = BGContinuedProcessingTaskRequest(
                identifier: identifier,
                title: "Memex Agent",
                subtitle: subtitle(for: snapshot)
            )
            request.strategy = .queue

            do {
                try BGTaskScheduler.shared.submit(request)
                submittedContinuedIdentifier = identifier
                startProgressPulse()
            } catch {
                NSLog("Memex: BGContinuedProcessingTask submit failed: %@", String(describing: error))
            }
        }
    }

    @available(iOS 26.0, *)
    private func registerContinuedProcessingHandler(identifier: String) -> Bool {
        if registeredContinuedIdentifiers.contains(identifier) {
            return true
        }

        let registered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: DispatchQueue.main
        ) { [weak self] task in
            guard let self = self, let task = task as? BGContinuedProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleContinuedProcessingTask(task)
        }

        if registered {
            registeredContinuedIdentifiers.insert(identifier)
        } else {
            NSLog("Memex: failed to register BGContinuedProcessingTask handler for %@", identifier)
        }

        return registered
    }

    private func updateContinuedProgress(snapshot: [String: Any], completed: Int64?) {
        if #available(iOS 26.0, *) {
            guard let task = continuedProcessingTask else { return }
            task.progress.totalUnitCount = 100
            if let completed = completed {
                task.progress.completedUnitCount = min(100, max(task.progress.completedUnitCount, completed))
            } else {
                task.progress.completedUnitCount = min(95, max(task.progress.completedUnitCount, syntheticProgress))
            }
            task.updateTitle(task.title, subtitle: subtitle(for: snapshot))
        }
    }

    private func completeContinuedProcessingIfSupported(success: Bool) {
        if #available(iOS 26.0, *) {
            if success {
                continuedProcessingTask?.progress.completedUnitCount = 100
            }
            continuedProcessingTask?.setTaskCompleted(success: success)
            continuedProcessingTask = nil
            submittedContinuedIdentifier = nil
        }
    }

    private func subtitle(for snapshot: [String: Any]) -> String {
        let total = snapshot["total"] as? Int ?? 0
        if total <= 0 {
            return "Finishing current work"
        }
        return "Processing \(total) queued task\(total == 1 ? "" : "s")"
    }
}
