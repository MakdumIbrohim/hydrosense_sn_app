import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perangkat Saya')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.developer_board, color: Colors.green),
              title: const Text('ESP32 Area Barat'),
              subtitle: const Text('Status: Online'),
              trailing: IconButton(
                icon: const Icon(Icons.settings_input_component),
                onPressed: () => context.go(AppRoutes.calibrateDevice('esp32-barat')),
                tooltip: 'Kalibrasi',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.developer_board, color: Colors.grey),
              title: const Text('ESP32 Tandon Utama'),
              subtitle: const Text('Status: Offline'),
              trailing: IconButton(
                icon: const Icon(Icons.settings_input_component),
                onPressed: () => context.go(AppRoutes.calibrateDevice('esp32-tandon')),
                tooltip: 'Kalibrasi',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addDevice),
        child: const Icon(Icons.add),
      ),
    );
  }
}