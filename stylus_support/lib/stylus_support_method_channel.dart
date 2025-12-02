import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'stylus_support_platform_interface.dart';
import 'stylus_event.dart';

/// An implementation of [StylusSupportPlatform] that uses method channels.
class MethodChannelStylusSupport extends StylusSupportPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stylus_support');

  /// The event channel used to receive stylus events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('stylus_support_events');

  /// Stream controller for stylus events
  StreamController<StylusEvent>? _stylusEventController;
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> getStylusSupport() async {
    await methodChannel.invokeMethod<void>('getStylusSupport');
  }

  @override
  Stream<StylusEvent> get stylusEventStream {
    debugPrint('Getting stylus event stream');
    _stylusEventController ??= StreamController<StylusEvent>.broadcast();
    
    // Start listening to events if not already listening
    if (_eventSubscription == null) {
      debugPrint('Setting up event subscription');
      _eventSubscription = eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          //debugPrint('Raw event received: $event');
          try {
            if (event is Map) {
              //debugPrint('Parsing event map: $event');
              final stylusEvent = StylusEvent.fromMap(Map<String, dynamic>.from(event));
              //debugPrint('Created stylus event: $stylusEvent');
              _stylusEventController?.add(stylusEvent);
            }
            else {
              //debugPrint('Event is not a Map: ${event.runtimeType}');
            }
          } catch (e) {
            // Log error but don't crash the stream
            debugPrint('Error parsing stylus event: $e');
            debugPrint('Event that caused error: $event');
          }
        },
        onError: (error) {
          debugPrint('Stylus event stream error: $error');
          _stylusEventController?.addError(error);
        },
        onDone: () {
          debugPrint('Stylus event stream done');
          _stylusEventController?.close();
        },
      );
      debugPrint('Event subscription created');
    } else {
      debugPrint('Event subscription already exists');
    }
    
    return _stylusEventController!.stream;
  }

  @override
  Future<bool> isStylusSupported() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isStylusSupported');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking stylus support: $e');
      return false;
    }
  }

  @override
  Future<void> setStylusMonitoringEnabled(bool enabled) async {
    try {
      await methodChannel.invokeMethod<void>('setStylusMonitoringEnabled', {'enabled': enabled});
      
      if (!enabled && _eventSubscription != null) {
        await _eventSubscription!.cancel();
        _eventSubscription = null;
      }
    } catch (e) {
      debugPrint('Error setting stylus monitoring: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isStylusMonitoringEnabled() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isStylusMonitoringEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking stylus monitoring status: $e');
      return false;
    }
  }

  @override
  Future<String> testEventChannel() async {
    try {
      final result = await methodChannel.invokeMethod<String>('testEventChannel');
      return result ?? 'No result';
    } catch (e) {
      debugPrint('Error testing event channel: $e');
      return 'Error: $e';
    }
  }

  /// Dispose resources when the plugin is no longer needed
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    await _stylusEventController?.close();
    _stylusEventController = null;
  }
}
