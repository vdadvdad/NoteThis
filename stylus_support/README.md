# Stylus Support Plugin

A Flutter plugin for stylus support with pressure sensitivity and tilt detection.

## Features

- **Pressure Sensitivity**: Get real-time pressure values (0.0 to 1.0)
- **Tilt Detection**: Monitor stylus tilt angles (-90° to 90°)
- **Azimuth Tracking**: Track stylus rotation (0° to 360°)
- **Position Tracking**: Get precise x, y coordinates
- **Event Types**: Detect press, move, release, enter, and exit events
- **Stream-based API**: Real-time event streaming with proper error handling

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  stylus_support: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:stylus_support/stylus_support.dart';

// Create an instance
final stylusSupport = StylusSupport();

// Check if stylus is supported
final isSupported = await stylusSupport.isStylusSupported();

if (isSupported) {
  // Enable monitoring
  await stylusSupport.setStylusMonitoringEnabled(true);
  
  // Listen to stylus events
  stylusSupport.stylusEventStream.listen((event) {
    print('Pressure: ${event.pressure}');
    print('Tilt: ${event.tilt}°');
    print('Position: (${event.x}, ${event.y})');
    print('Event Type: ${event.eventType}');
  });
}
```

### Advanced Usage with Stream Management

```dart
import 'package:stylus_support/stylus_support.dart';
import 'dart:async';

class StylusWidget extends StatefulWidget {
  @override
  _StylusWidgetState createState() => _StylusWidgetState();
}

class _StylusWidgetState extends State<StylusWidget> {
  final StylusSupport _stylusSupport = StylusSupport();
  StreamSubscription<StylusEvent>? _subscription;
  
  @override
  void initState() {
    super.initState();
    _initializeStylus();
  }
  
  Future<void> _initializeStylus() async {
    if (await _stylusSupport.isStylusSupported()) {
      await _stylusSupport.setStylusMonitoringEnabled(true);
      
      _subscription = _stylusSupport.stylusEventStream.listen(
        (event) {
          // Handle stylus events
          setState(() {
            // Update UI with stylus data
          });
        },
        onError: (error) {
          print('Stylus error: $error');
        },
      );
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _stylusSupport.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Simplified MousePressure Interface

For simpler use cases, you can use the `MousePressure` class:

```dart
import 'package:stylus_support/mouse_pressure.dart';

// Start monitoring with a callback
MousePressure.startMonitoring(
  onEvent: (event) {
    print('Pressure: ${event.pressure}');
    print('Tilt: ${event.tilt}°');
  },
);

// Or use specific streams
MousePressure.pressureStream.listen((pressure) {
  print('Pressure: $pressure');
});

MousePressure.tiltStream.listen((tilt) {
  print('Tilt: $tilt°');
});

MousePressure.positionStream.listen((position) {
  print('Position: (${position.x}, ${position.y})');
});
```

### Using StreamBuilder

```dart
StreamBuilder<StylusEvent>(
  stream: stylusSupport.stylusEventStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final event = snapshot.data!;
      return Text('Pressure: ${(event.pressure * 100).toStringAsFixed(1)}%');
    }
    return Text('No stylus data');
  },
)
```

## API Reference

### StylusEvent

Represents a stylus event with all available data:

```dart
class StylusEvent {
  final double pressure;      // 0.0 to 1.0
  final double tilt;          // -90° to 90°
  final double azimuth;       // 0° to 360°
  final DateTime timestamp;   // Event timestamp
  final double x;             // X coordinate
  final double y;             // Y coordinate
  final bool isInContact;     // Contact status
  final StylusEventType eventType; // Event type
}
```

### StylusEventType

```dart
enum StylusEventType {
  pressed,   // Stylus pressed down
  moved,     // Stylus moved while pressed
  released,  // Stylus released
  entered,   // Stylus entered surface area
  exited,    // Stylus exited surface area
  unknown,   // Unknown event type
}
```

### StylusSupport Methods

- `getPlatformVersion()`: Get the platform version
- `getStylusSupport()`: Get stylus support information
- `stylusEventStream`: Stream of stylus events
- `isStylusSupported()`: Check if stylus is supported
- `setStylusMonitoringEnabled(bool)`: Enable/disable monitoring
- `isStylusMonitoringEnabled()`: Get monitoring status
- `dispose()`: Clean up resources

### MousePressure Methods

- `startMonitoring({onEvent})`: Start monitoring with callback
- `stream`: Stream of all stylus events
- `pressureStream`: Stream of pressure values only
- `tiltStream`: Stream of tilt values only
- `azimuthStream`: Stream of azimuth values only
- `positionStream`: Stream of position coordinates only

## Platform Support

Currently supports:
- macOS (with proper native implementation)

## Error Handling

The plugin includes comprehensive error handling:

- Graceful degradation when stylus is not supported
- Stream error handling with proper error propagation
- Resource cleanup on dispose
- Null safety throughout the API

## Example

See `example_usage.dart` for complete working examples.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.

