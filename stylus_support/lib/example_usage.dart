import 'package:flutter/material.dart';
import 'dart:async';
import 'stylus_support.dart';
import 'stylus_event.dart';
import 'mouse_pressure.dart';

/// Example widget demonstrating how to use the stylus support plugin
class StylusExampleWidget extends StatefulWidget {
  const StylusExampleWidget({super.key});

  @override
  State<StylusExampleWidget> createState() => _StylusExampleWidgetState();
}

class _StylusExampleWidgetState extends State<StylusExampleWidget> {
  final StylusSupport _stylusSupport = StylusSupport();
  StreamSubscription<StylusEvent>? _stylusSubscription;
  
  String _lastEvent = 'No events yet';
  double _currentPressure = 0.0;
  double _currentTilt = 0.0;
  double _currentX = 0.0;
  double _currentY = 0.0;
  bool _isStylusSupported = false;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _initializeStylusSupport();
  }

  Future<void> _initializeStylusSupport() async {
    try {
      // Check if stylus is supported
      final supported = await _stylusSupport.isStylusSupported();
      setState(() {
        _isStylusSupported = supported;
      });

      if (supported) {
        // Start monitoring stylus events
        await _stylusSupport.setStylusMonitoringEnabled(true);
        setState(() {
          _isMonitoring = true;
        });

        // Listen to stylus events
        _stylusSubscription = _stylusSupport.stylusEventStream.listen(
          (event) {
            setState(() {
              _lastEvent = event.toString();
              _currentPressure = event.pressure;
              _currentTilt = event.tilt;
              _currentX = event.x;
              _currentY = event.y;
            });
          },
          onError: (error) {
            print('Stylus event error: $error');
            setState(() {
              _lastEvent = 'Error: $error';
            });
          },
        );
      }
    } catch (e) {
      print('Error initializing stylus support: $e');
      setState(() {
        _lastEvent = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _stylusSubscription?.cancel();
    _stylusSupport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stylus Support Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stylus Supported: $_isStylusSupported',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Monitoring: $_isMonitoring',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Current Pressure: ${(_currentPressure * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Current Tilt: ${_currentTilt.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Position: (${_currentX.toStringAsFixed(1)}, ${_currentY.toStringAsFixed(1)})',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Last Event:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _lastEvent,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleMonitoring,
              child: Text(_isMonitoring ? 'Stop Monitoring' : 'Start Monitoring'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMonitoring() async {
    try {
      final newState = !_isMonitoring;
      await _stylusSupport.setStylusMonitoringEnabled(newState);
      
      if (newState) {
        _stylusSubscription = _stylusSupport.stylusEventStream.listen(
          (event) {
            setState(() {
              _lastEvent = event.toString();
              _currentPressure = event.pressure;
              _currentTilt = event.tilt;
              _currentX = event.x;
              _currentY = event.y;
            });
          },
        );
      } else {
        await _stylusSubscription?.cancel();
        _stylusSubscription = null;
      }
      
      setState(() {
        _isMonitoring = newState;
      });
    } catch (e) {
      print('Error toggling monitoring: $e');
    }
  }
}

/// Example using the simplified MousePressure interface
class SimpleStylusExample extends StatefulWidget {
  const SimpleStylusExample({super.key});

  @override
  State<SimpleStylusExample> createState() => _SimpleStylusExampleState();
}

class _SimpleStylusExampleState extends State<SimpleStylusExample> {
  double _pressure = 0.0;
  double _tilt = 0.0;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    // Using the simplified MousePressure interface
    MousePressure.startMonitoring(
      onEvent: (event) {
        setState(() {
          _pressure = event.pressure;
          _tilt = event.tilt;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Stylus Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pressure: ${(_pressure * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tilt: ${_tilt.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Example of using specific streams
            StreamBuilder<double>(
              stream: MousePressure.pressureStream,
              builder: (context, snapshot) {
                return Text(
                  'Pressure Stream: ${snapshot.hasData ? (snapshot.data! * 100).toStringAsFixed(1) : 'No data'}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<({double x, double y})>(
              stream: MousePressure.positionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Position Stream: (${snapshot.data!.x.toStringAsFixed(1)}, ${snapshot.data!.y.toStringAsFixed(1)})',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
                return const Text('Position Stream: No data');
              },
            ),
          ],
        ),
      ),
    );
  }
}
