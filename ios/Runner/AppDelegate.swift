import Flutter
import UIKit
import WebKit
import workmanager_apple
import EventKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    // Register Workmanager task
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }
    // Required for BGTaskScheduler
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "workmanager.background.task", frequency: NSNumber(value: 20 * 60))

    let webViewChannel = FlutterMethodChannel(
      name: "com.memexlab.memex/webview",
      binaryMessenger: controller.binaryMessenger
    )
    
    webViewChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "disableScrolling" {
        // Find all WKWebView instances and disable scrolling.
        self?.disableWebViewScrolling()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
}
    
    let storageChannel = FlutterMethodChannel(
      name: "com.memexlab.memex/storage",
      binaryMessenger: controller.binaryMessenger
    )
    storageChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getICloudContainerPath" {
        DispatchQueue.global(qos: .userInitiated).async {
          // Prefer explicit container ID to avoid ambiguity.
          let explicitContainer = "iCloud.com.memexlab.memex"
          var url = FileManager.default.url(forUbiquityContainerIdentifier: explicitContainer)
          if url == nil {
            // Fallback to default container if explicit lookup failed.
            url = FileManager.default.url(forUbiquityContainerIdentifier: nil)
          }
          DispatchQueue.main.async {
            if let url = url {
              NSLog("[iCloud] container path resolved: \(url.path)")
              result(url.path)
            } else {
              let hasIdentity = FileManager.default.ubiquityIdentityToken != nil
              NSLog("[iCloud] container path is nil. ubiquityIdentityToken exists: \(hasIdentity)")
              result(nil)
            }
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let systemActionsChannel = FlutterMethodChannel(
      name: "com.memexlab.memex/system_actions",
      binaryMessenger: controller.binaryMessenger
    )
    
    systemActionsChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      let eventStore = EKEventStore()
      
      if call.method == "addCalendarEvent" {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let startMs = args["startTime"] as? Int64,
              let endMs = args["endTime"] as? Int64 else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for addCalendarEvent", details: nil))
          return
        }
        
        let startDate = Date(timeIntervalSince1970: TimeInterval(startMs) / 1000.0)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endMs) / 1000.0)
        let location = args["location"] as? String
        let notes = args["notes"] as? String
        
        let requestCompletion: (Bool, Error?) -> Void = { (granted, error) in
          if granted && error == nil {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.location = location
            event.notes = notes
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
              try eventStore.save(event, span: .thisEvent)
              DispatchQueue.main.async { result(true) }
            } catch {
              DispatchQueue.main.async { result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil)) }
            }
          } else {
            DispatchQueue.main.async { result(FlutterError(code: "PERMISSION_DENIED", message: "Calendar permission denied", details: nil)) }
          }
        }
        
        if #available(iOS 17.0, *) {
            eventStore.requestWriteOnlyAccessToEvents(completion: requestCompletion)
        } else {
            eventStore.requestAccess(to: .event, completion: requestCompletion)
        }
      } else if call.method == "addReminder" {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for addReminder", details: nil))
          return
        }
        
        let dueMs = args["dueDate"] as? Int64
        let notes = args["notes"] as? String
        
        let requestCompletion: (Bool, Error?) -> Void = { (granted, error) in
          if granted && error == nil {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = title
            reminder.notes = notes
            guard let calendar = eventStore.defaultCalendarForNewReminders() else {
                DispatchQueue.main.async { result(FlutterError(code: "NO_CALENDAR", message: "No default reminders calendar", details: nil)) }
                return
            }
            reminder.calendar = calendar
            
            if let dueMs = dueMs {
              let dueDate = Date(timeIntervalSince1970: TimeInterval(dueMs) / 1000.0)
              let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDate)
              reminder.dueDateComponents = components
              let alarm = EKAlarm(absoluteDate: dueDate)
              reminder.addAlarm(alarm)
            }
            
            do {
              try eventStore.save(reminder, commit: true)
              DispatchQueue.main.async { result(true) }
            } catch {
              DispatchQueue.main.async { result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil)) }
            }
          } else {
            DispatchQueue.main.async { result(FlutterError(code: "PERMISSION_DENIED", message: "Reminder permission denied", details: nil)) }
          }
        }
        
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders(completion: requestCompletion)
        } else {
            eventStore.requestAccess(to: .reminder, completion: requestCompletion)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func disableWebViewScrolling() {
    // Traverse the view hierarchy to find WKWebView instances.
    if let window = self.window {
      disableScrollingInView(window)
    }
  }
  
  private func disableScrollingInView(_ view: UIView) {
    if let webView = view as? WKWebView {
      webView.scrollView.isScrollEnabled = false
      webView.scrollView.showsVerticalScrollIndicator = false
      webView.scrollView.showsHorizontalScrollIndicator = false
      webView.scrollView.bounces = false
      webView.scrollView.alwaysBounceVertical = false
      webView.scrollView.alwaysBounceHorizontal = false
    }
    
    for subview in view.subviews {
      disableScrollingInView(subview)
    }
  }
}
