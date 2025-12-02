import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

import 'stylus_support_method_channel.dart';
import 'stylus_event.dart';

abstract class StylusSupportPlatform extends PlatformInterface {
  /// Constructs a StylusSupportPlatform.
  StylusSupportPlatform() : super(token: _token);

  static final Object _token = Object();

  static StylusSupportPlatform _instance = MethodChannelStylusSupport();

  /// The default instance of [StylusSupportPlatform] to use.
  ///
  /// Defaults to [MethodChannelStylusSupport].
  static StylusSupportPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StylusSupportPlatform] when
  /// they register themselves.
  static set instance(StylusSupportPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get the platform version
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Get stylus support information
  Future<void> getStylusSupport() {
    throw UnimplementedError('getStylusSupport() has not been implemented.');
  }

  /// Start monitoring stylus events
  /// Returns a stream of [StylusEvent] objects
  Stream<StylusEvent> get stylusEventStream {
    throw UnimplementedError('stylusEventStream has not been implemented.');
  }

  /// Check if stylus support is available on this platform
  Future<bool> isStylusSupported() {
    throw UnimplementedError('isStylusSupported() has not been implemented.');
  }

  /// Enable or disable stylus event monitoring
  Future<void> setStylusMonitoringEnabled(bool enabled) {
    throw UnimplementedError('setStylusMonitoringEnabled() has not been implemented.');
  }

  /// Get current stylus monitoring status
  Future<bool> isStylusMonitoringEnabled() {
    throw UnimplementedError('isStylusMonitoringEnabled() has not been implemented.');
  }

  /// Test the event channel by sending a test event
  Future<String> testEventChannel() {
    throw UnimplementedError('testEventChannel() has not been implemented.');
  }
}
