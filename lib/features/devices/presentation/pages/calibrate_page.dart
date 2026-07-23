import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalibratePage extends StatelessWidget {
  final String id;
  const CalibratePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calibrate Device $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sensor Calibration'),
            ElevatedButton(onPressed: () => context.go('/devices'), child: const Text('Back to Devices')),
          ],
        ),
      ),
    );
  }
}