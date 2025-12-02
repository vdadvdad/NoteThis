import 'package:flutter/material.dart';
import 'package:stylus_support/stylus_support.dart';
import 'package:stylus_support/stylus_event.dart';
import 'dart:async';

class StylusTestWidget extends StatefulWidget {
  const StylusTestWidget({super.key});

  @override
  State<StylusTestWidget> createState() => _StylusTestWidgetState();
}

class _StylusTestWidgetState extends State<StylusTestWidget> {
  final StylusSupport _stylusSupport = StylusSupport();
  StreamSubscription<StylusEvent>? _stylusSubscription;
  String _status = 'Initializing...';
  String _lastEvent = 'No events yet';
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    _initializeStylus();
  }

  Future<void> _initializeStylus() async {
    try {
      setState(() {
        _status = 'Checking stylus support...';
      });

      final supported = await _stylusSupport.isStylusSupported();
      
      setState(() {
        _isSupported = supported;
        _status = supported ? 'Stylus supported' : 'Stylus not supported';
      });

      if (supported) {
        await _stylusSupport.setStylusMonitoringEnabled(true);
        
        _stylusSubscription = _stylusSupport.stylusEventStream.listen(
          (event) {
            print('Flutter received stylus event: $event');
            setState(() {
              _lastEvent = 'Pressure: ${(event.pressure * 100).toStringAsFixed(1)}%, '
                         'Tilt: ${event.tilt.toStringAsFixed(1)}°, '
                         'Position: (${event.x.toStringAsFixed(1)}, ${event.y.toStringAsFixed(1)})';
            });
          },
          onError: (error) {
            print('Flutter stylus stream error: $error');
            setState(() {
              _lastEvent = 'Error: $error';
            });
          },
        );
        
        print('Flutter stream subscription created');
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
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
        title: const Text('Stylus Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Stylus Supported: $_isSupported',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Last Event:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Text(
                _lastEvent,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lastEvent = 'Button pressed at ${DateTime.now().toString()}';
                });
                print('Test button pressed');
              },
              child: const Text('Test Button (to verify UI updates)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await _stylusSupport.testEventChannel();
                  setState(() {
                    _lastEvent = 'Test event result: $result';
                  });
                  print('Test event channel result: $result');
                } catch (e) {
                  setState(() {
                    _lastEvent = 'Test event error: $e';
                  });
                  print('Test event channel error: $e');
                }
              },
              child: const Text('Test Event Channel'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• If you have a stylus, try using it on this screen'),
            const Text('• If you don\'t have a stylus, the status will show "Stylus not supported"'),
            const Text('• This tests the basic functionality of the stylus support plugin'),
            const Text('• Check console for debug messages'),
          ],
        ),
      ),
    );
  }
}
