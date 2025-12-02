import 'package:flutter_test/flutter_test.dart';
import 'package:stylus_support/stylus_support.dart';
import 'package:stylus_support/stylus_event.dart';
import 'package:stylus_support/mouse_pressure.dart';

void main() {
  group('StylusSupport Tests', () {
    test('StylusEvent.fromMap creates correct object', () {
      final map = {
        'pressure': 0.5,
        'tilt': 45.0,
        'azimuth': 180.0,
        'timestamp': 1234567890,
        'x': 100.0,
        'y': 200.0,
        'isInContact': true,
        'eventType': 'pressed',
      };

      final event = StylusEvent.fromMap(map);

      expect(event.pressure, 0.5);
      expect(event.tilt, 45.0);
      expect(event.azimuth, 180.0);
      expect(event.x, 100.0);
      expect(event.y, 200.0);
      expect(event.isInContact, true);
      expect(event.eventType, StylusEventType.pressed);
    });

    test('StylusEvent.toMap creates correct map', () {
      final event = StylusEvent(
        pressure: 0.75,
        tilt: 30.0,
        azimuth: 90.0,
        timestamp: DateTime(2023, 1, 1),
        x: 150.0,
        y: 250.0,
        isInContact: false,
        eventType: StylusEventType.moved,
      );

      final map = event.toMap();

      expect(map['pressure'], 0.75);
      expect(map['tilt'], 30.0);
      expect(map['azimuth'], 90.0);
      expect(map['x'], 150.0);
      expect(map['y'], 250.0);
      expect(map['isInContact'], false);
      expect(map['eventType'], 'moved');
    });

    test('StylusEvent handles null values gracefully', () {
      final map = {
        'pressure': null,
        'tilt': null,
        'azimuth': null,
        'timestamp': null,
        'x': null,
        'y': null,
        'isInContact': null,
        'eventType': 'unknown',
      };

      final event = StylusEvent.fromMap(map);

      expect(event.pressure, 0.0);
      expect(event.tilt, 0.0);
      expect(event.azimuth, 0.0);
      expect(event.x, 0.0);
      expect(event.y, 0.0);
      expect(event.isInContact, false);
      expect(event.eventType, StylusEventType.unknown);
    });

    test('StylusEventType enum values are correct', () {
      expect(StylusEventType.pressed.name, 'pressed');
      expect(StylusEventType.moved.name, 'moved');
      expect(StylusEventType.released.name, 'released');
      expect(StylusEventType.entered.name, 'entered');
      expect(StylusEventType.exited.name, 'exited');
      expect(StylusEventType.unknown.name, 'unknown');
    });

    test('StylusSupport instance can be created', () {
      final stylusSupport = StylusSupport();
      expect(stylusSupport, isNotNull);
    });

    test('MousePressure class exists and has expected methods', () {
      expect(MousePressure.stream, isNotNull);
      expect(() => MousePressure.startMonitoring(), returnsNormally);
      expect(MousePressure.pressureStream, isNotNull);
      expect(MousePressure.tiltStream, isNotNull);
      expect(MousePressure.azimuthStream, isNotNull);
      expect(MousePressure.positionStream, isNotNull);
    });
  });

  group('Stream Tests', () {
    test('MousePressure streams are properly typed', () {
      expect(MousePressure.pressureStream, isA<Stream<double>>());
      expect(MousePressure.tiltStream, isA<Stream<double>>());
      expect(MousePressure.azimuthStream, isA<Stream<double>>());
      expect(MousePressure.positionStream, isA<Stream<({double x, double y})>>());
    });

    test('StylusSupport has stylusEventStream', () {
      final stylusSupport = StylusSupport();
      expect(stylusSupport.stylusEventStream, isA<Stream<StylusEvent>>());
    });
  });
}
