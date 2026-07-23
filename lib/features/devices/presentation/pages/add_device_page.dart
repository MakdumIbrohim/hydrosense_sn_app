import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Device')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pairing WiFi/Bluetooth'),
            ElevatedButton(onPressed: () => context.go('/devices'), child: const Text('Back to Devices')),
          ],
        ),
      ),
    );
  }
}