
import 'stylus_support_platform_interface.dart';
import 'stylus_support_method_channel.dart';
import 'stylus_event.dart';
export 'example_usage.dart';

/// A Flutter plugin for stylus support with pressure sensitivity and tilt detection.
class StylusSupport {
  /// Get the platform version
  Future<String?> getPlatformVersion() {
    return StylusSupportPlatform.instance.getPlatformVersion();
  }

  /// Get stylus support information
  Future<void> getStylusSupport() {
    return StylusSupportPlatform.instance.getStylusSupport();
  }

  /// Get a stream of stylus events
  /// 
  /// This stream provides real-time stylus data including:
  /// - Pressure (0.0 to 1.0)
  /// - Tilt angle (-90 to 90 degrees)
  /// - Azimuth angle (0 to 360 degrees)
  /// - Position (x, y coordinates)
  /// - Contact status
  /// - Event type (pressed, moved, released, etc.)
  Stream<StylusEvent> get stylusEventStream {
    return StylusSupportPlatform.instance.stylusEventStream;
  }

  /// Check if stylus support is available on this platform
  Future<bool> isStylusSupported() {
    return StylusSupportPlatform.instance.isStylusSupported();
  }

  /// Enable or disable stylus event monitoring
  /// 
  /// When enabled, the plugin will start monitoring for stylus events
  /// and emit them through the [stylusEventStream].
  /// 
  /// When disabled, no events will be emitted and system resources
  /// will be freed.
  Future<void> setStylusMonitoringEnabled(bool enabled) {
    return StylusSupportPlatform.instance.setStylusMonitoringEnabled(enabled);
  }

  /// Get current stylus monitoring status
  Future<bool> isStylusMonitoringEnabled() {
    return StylusSupportPlatform.instance.isStylusMonitoringEnabled();
  }

  /// Test the event channel by sending a test event
  Future<String> testEventChannel() {
    return StylusSupportPlatform.instance.testEventChannel();
  }

  /// Dispose of the plugin resources
  /// 
  /// Call this when you're done using the plugin to free up resources.
  Future<void> dispose() async {
    if (StylusSupportPlatform.instance is MethodChannelStylusSupport) {
      await (StylusSupportPlatform.instance as MethodChannelStylusSupport).dispose();
    }
  }
}
