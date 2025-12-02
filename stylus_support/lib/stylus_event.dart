/// Represents a stylus event with pressure, tilt, and other relevant data
class StylusEvent {
  /// The pressure value (0.0 to 1.0)
  final double pressure;
  
  /// The tilt angle in degrees (-90 to 90)
  final double tilt;
  
  /// The azimuth angle in degrees (0 to 360)
  final double azimuth;
  
  /// The timestamp of the event
  final DateTime timestamp;
  
  /// The x coordinate of the stylus
  final double x;
  
  /// The y coordinate of the stylus
  final double y;
  
  /// Whether the stylus is in contact with the surface
  final bool isInContact;
  
  /// The type of stylus event
  final StylusEventType eventType;

  const StylusEvent({
    required this.pressure,
    required this.tilt,
    required this.azimuth,
    required this.timestamp,
    required this.x,
    required this.y,
    required this.isInContact,
    required this.eventType,
  });

  /// Create a StylusEvent from a map (typically from platform channel)
  factory StylusEvent.fromMap(Map<String, dynamic> map) {
    return StylusEvent(
      pressure: (map['pressure'] as num?)?.toDouble() ?? 0.0,
      tilt: (map['tilt'] as num?)?.toDouble() ?? 0.0,
      azimuth: (map['azimuth'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      isInContact: map['isInContact'] as bool? ?? false,
      eventType: StylusEventType.values.firstWhere(
        (type) => type.name == map['eventType'],
        orElse: () => StylusEventType.unknown,
      ),
    );
  }

  /// Convert to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'pressure': pressure,
      'tilt': tilt,
      'azimuth': azimuth,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'x': x,
      'y': y,
      'isInContact': isInContact,
      'eventType': eventType.name,
    };
  }

  @override
  String toString() {
    return 'StylusEvent(pressure: $pressure, tilt: $tilt, azimuth: $azimuth, '
           'x: $x, y: $y, isInContact: $isInContact, eventType: $eventType)';
  }
}

/// Types of stylus events
enum StylusEventType {
  /// Stylus pressed down
  pressed,
  
  /// Stylus moved while pressed
  moved,
  
  /// Stylus released
  released,
  
  /// Stylus entered the surface area
  entered,
  
  /// Stylus exited the surface area
  exited,
  
  /// Unknown event type
  unknown,
}
