import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LA DEYYEH GELLUN'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.settings),
              child: const Text('Ke Settings'),
            ),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.devices),
              child: const Text('Ke Devices'),
            ),
          ],
        ),
      ),
    );
  }
}