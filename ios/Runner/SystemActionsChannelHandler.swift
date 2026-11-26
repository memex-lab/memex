import Flutter
import EventKit
import EventKitUI
import UIKit

/// Handles `com.memexlab.memex/system_actions` MethodChannel.
/// Supports: addCalendarEvent, addReminder.
class SystemActionsChannelHandler: NSObject, EKEventEditViewDelegate {

    private var calendarResult: FlutterResult?
    private var calendarEditor: EKEventEditViewController?

    private let eventStore = EKEventStore()

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.memexlab.memex/system_actions",
            binaryMessenger: messenger
        )
        let instance = SystemActionsChannelHandler()
        channel.setMethodCallHandler(instance.handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addCalendarEvent":
            addCalendarEvent(call: call, result: result)
        case "addReminder":
            addReminder(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Calendar Event

    private func addCalendarEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let startMs = args["startTime"] as? Int64,
              let endMs = args["endTime"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Invalid arguments for addCalendarEvent", details: nil))
            return
        }

        let startDate = Date(timeIntervalSince1970: TimeInterval(startMs) / 1000.0)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endMs) / 1000.0)
        let location = args["location"] as? String
        let notes = args["notes"] as? String

        DispatchQueue.main.async {
            guard self.calendarResult == nil else {
                result(FlutterError(code: "EDITOR_BUSY", message: "Calendar editor already open", details: nil))
                return
            }
            self.calendarResult = result
            let presentEditor = {
                guard let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                      var presenter = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                    self.finishCalendar(FlutterError(code: "NO_PRESENTER", message: "No active window", details: nil))
                    return
                }
                while let presented = presenter.presentedViewController {
                    presenter = presented
                }
                guard !presenter.isBeingDismissed, presenter.viewIfLoaded?.window != nil else {
                    self.finishCalendar(FlutterError(code: "NO_PRESENTER", message: "Window is transitioning", details: nil))
                    return
                }
                let event = EKEvent(eventStore: self.eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.location = location
                event.notes = notes
                let editor = EKEventEditViewController()
                editor.eventStore = self.eventStore
                editor.event = event
                editor.editViewDelegate = self
                // Dismiss through the system Cancel button so the result always resolves.
                editor.isModalInPresentation = true
                self.calendarEditor = editor
                presenter.present(editor, animated: true)
            }
            if #available(iOS 17.0, *) {
                // EventKitUI handles saving without granting Memex calendar access.
                presentEditor()
            } else {
                self.requestCalendarAccess { granted, error in
                    DispatchQueue.main.async {
                        if granted && error == nil {
                            presentEditor()
                        } else {
                            self.finishCalendar(FlutterError(code: "PERMISSION_DENIED", message: "Calendar permission denied", details: nil))
                        }
                    }
                }
            }
        }
    }

    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {
        guard controller === calendarEditor else { return }
        controller.dismiss(animated: true) {
            self.finishCalendar(action == .saved ? (true as Any) : ("cancelled" as Any))
        }
    }

    private func finishCalendar(_ value: Any) {
        let result = calendarResult
        calendarResult = nil
        calendarEditor = nil
        result?(value)
    }

    // MARK: - Reminder

    private func addReminder(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let dueMs = args["dueDate"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Invalid arguments for addReminder", details: nil))
            return
        }

        let notes = args["notes"] as? String

        requestReminderAccess { [weak self] granted, error in
            guard let self = self else { return }
            guard granted, error == nil else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "PERMISSION_DENIED",
                                        message: "Reminder permission denied", details: nil))
                }
                return
            }

            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = title
            reminder.notes = notes

            guard let calendar = self.eventStore.defaultCalendarForNewReminders() else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "NO_CALENDAR",
                                        message: "No default reminders calendar", details: nil))
                }
                return
            }
            reminder.calendar = calendar

            let dueDate = Date(timeIntervalSince1970: TimeInterval(dueMs) / 1000.0)
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second], from: dueDate)
            reminder.dueDateComponents = components
            reminder.addAlarm(EKAlarm(absoluteDate: dueDate))

            do {
                try self.eventStore.save(reminder, commit: true)
                DispatchQueue.main.async { result(true) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SAVE_ERROR",
                                        message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    // MARK: - Permission Helpers

    private func requestCalendarAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestWriteOnlyAccessToEvents(completion: completion)
        } else {
            eventStore.requestAccess(to: .event, completion: completion)
        }
    }

    private func requestReminderAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders(completion: completion)
        } else {
            eventStore.requestAccess(to: .reminder, completion: completion)
        }
    }
}
