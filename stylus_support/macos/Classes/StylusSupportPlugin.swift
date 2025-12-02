import Cocoa
import FlutterMacOS

public class StylusSupportPlugin: NSObject, FlutterPlugin {
  private var eventMonitor: Any?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "stylus_support", binaryMessenger: registrar.messenger)
    let eventChannel = FlutterEventChannel(name: "stylus_support_events", binaryMessenger: registrar.messenger)
    let instance = StylusSupportPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "getStylusSupport":
      result("Stylus support initialized")
    case "isStylusSupported":
      result(true) // macOS generally supports stylus input
    case "setStylusMonitoringEnabled":
      if let args = call.arguments as? [String: Any],
         let enabled = args["enabled"] as? Bool {
        if enabled {
          startStylusMonitoring()
          print("Stylus monitoring started")
        } else {
          stopStylusMonitoring()
          print("Stylus monitoring stopped")
        }
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
    case "isStylusMonitoringEnabled":
      result(eventMonitor != nil)
    case "testEventChannel":
      // Send a test event to verify the channel is working
      let testEvent: [String: Any] = [
        "pressure": 0.5,
        "tilt": 45.0,
        "azimuth": 180.0,
        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        "x": 100.0,
        "y": 200.0,
        "isInContact": true,
        "eventType": "pressed"
      ]
      
      if let sink = eventSink {
        print("Sending test event: \(testEvent)")
        sink(testEvent)
        result("Test event sent")
      } else {
        print("No event sink available for test")
        result("No event sink available")
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startStylusMonitoring() {
    stopStylusMonitoring() // Stop any existing monitoring
    
    // Monitor for all relevant stylus events
    let eventMask: NSEvent.EventTypeMask = [.pressure, .tabletProximity, .tabletPoint, .leftMouseDown, .leftMouseUp, .leftMouseDragged]
    
    eventMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
      return self?.handleEvent(event: event) ?? event
    }
    
    print("Event monitor created with mask: \(eventMask)")
  }
  
  private func stopStylusMonitoring() {
    if let monitor = eventMonitor {
      NSEvent.removeMonitor(monitor)
      eventMonitor = nil
    }
  }
  
  private func handleEvent(event: NSEvent) -> NSEvent? {
    print("Received event: \(event.type.rawValue)")
    
    var eventData: [String: Any] = [:]
    
    // Get pressure information
    if event.type == .pressure {
      eventData["pressure"] = event.pressure
      eventData["eventType"] = "pressed"
      print("Pressure event: \(event.pressure)")
    } else if event.type == .tabletProximity {
      eventData["eventType"] = event.isEnteringProximity ? "entered" : "exited"
      print("Tablet proximity: \(event.isEnteringProximity ? "entered" : "exited")")
    } else if event.type == .tabletPoint {
      eventData["eventType"] = "moved"
      print("Tablet point event")
    } else if event.type == .leftMouseDown {
      eventData["eventType"] = "pressed"
      print("Mouse down event")
    } else if event.type == .leftMouseUp {
      eventData["eventType"] = "released"
      print("Mouse up event")
    } else if event.type == .leftMouseDragged {
      eventData["eventType"] = "moved"
      print("Mouse dragged event")
    }
    
    // Get position
    eventData["x"] = event.locationInWindow.x
    eventData["y"] = event.locationInWindow.y
    
    // Get timestamp
    eventData["timestamp"] = Int(event.timestamp * 1000)
    
    // Get pressure (for all events)
    eventData["pressure"] = event.pressure
    
    // Get tilt and azimuth if available
    if event.type == .tabletPoint {
      eventData["tilt"] = event.tilt.x // X tilt
      eventData["azimuth"] = event.tilt.y // Y tilt (used as azimuth)
    } else {
      eventData["tilt"] = 0.0
      eventData["azimuth"] = 0.0
    }
    
    // Contact status
    eventData["isInContact"] = event.pressure > 0.0
    
    print("Sending event data: \(eventData)")
    
    // Send event to Flutter
    if let sink = eventSink {
      sink(eventData)
    } else {
      print("No event sink available")
    }
    
    return event
  }
}

// MARK: - FlutterStreamHandler
extension StylusSupportPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    print("Flutter stream listener started")
    self.eventSink = events
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    print("Flutter stream listener cancelled")
    self.eventSink = nil
    return nil
  }
}
