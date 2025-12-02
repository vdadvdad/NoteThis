import 'package:flutter/services.dart';
import 'dart:async';
import 'stylus_event.dart';

/// A simplified interface for mouse pressure and stylus events
class MousePressure {
  static const EventChannel _eventChannel = EventChannel('stylus_support');
  
  /// Get a stream of stylus events
  static Stream<StylusEvent> get stream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map<String, dynamic>) {
        return StylusEvent.fromMap(event);
      }
      throw FormatException('Invalid event format: $event');
    });
  }

  /// Start monitoring stylus events with a callback
  /// 
  /// This is a convenience method for simple use cases.
  /// For more control, use the [StylusSupport] class directly.
  static void startMonitoring({Function(StylusEvent)? onEvent}) {
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        try {
          if (event is Map<String, dynamic>) {
            final stylusEvent = StylusEvent.fromMap(event);
            onEvent?.call(stylusEvent);
          }
        } catch (e) {
          print("Error parsing stylus event: $e");
        }
      },
      onError: (error) {
        print("Stylus event stream error: $error");
      },
    );
  }

  /// Get a stream of pressure values only
  static Stream<double> get pressureStream {
    return stream.map((event) => event.pressure);
  }

  /// Get a stream of tilt values only
  static Stream<double> get tiltStream {
    return stream.map((event) => event.tilt);
  }

  /// Get a stream of azimuth values only
  static Stream<double> get azimuthStream {
    return stream.map((event) => event.azimuth);
  }

  /// Get a stream of position coordinates only
  static Stream<({double x, double y})> get positionStream {
    return stream.map((event) => (x: event.x, y: event.y));
  }
}