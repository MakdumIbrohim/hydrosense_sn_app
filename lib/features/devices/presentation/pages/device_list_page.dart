import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => context.go('/devices/add'), child: const Text('Add Device')),
            ElevatedButton(onPressed: () => context.go('/devices/123/calibrate'), child: const Text('Calibrate Device 123')),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('Back to Dashboard')),
          ],
        ),
      ),
    );
  }
}