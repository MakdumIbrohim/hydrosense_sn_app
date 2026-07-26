import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  void _showPinDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    bool isError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock, color: Color(0xFF0D6E6E)),
                  SizedBox(width: 8),
                  Text('Keamanan Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Masukkan PIN untuk membuka halaman konfigurasi jaringan ESP32.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'PIN Admin',
                      border: const OutlineInputBorder(),
                      errorText: isError ? 'PIN salah! Coba lagi.' : null,
                      prefixIcon: const Icon(Icons.password),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6E6E), 
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // PIN Rahasia (Ubah sesuai keinginan Anda)
                    if (pinController.text == '123456') {
                      Navigator.pop(context); // Tutup pop-up
                      context.go(AppRoutes.addDevice); // Buka halaman setup WiFi
                    } else {
                      setState(() {
                        isError = true;
                      });
                    }
                  },
                  child: const Text('Masuk'),
                ),
              ],
            );
          }
        );
      },
    );
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPinDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}