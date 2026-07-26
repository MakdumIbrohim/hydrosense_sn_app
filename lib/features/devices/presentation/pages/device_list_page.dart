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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perangkat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDeviceTile(
                      isDark: isDark,
                      cardColor: cardColor,
                      title: 'ESP32 Area Barat',
                      isOnline: true,
                      onCalibrate: () => context.go(AppRoutes.calibrateDevice('esp32-barat')),
                    ),
                    const SizedBox(height: 16),
                    _buildDeviceTile(
                      isDark: isDark,
                      cardColor: cardColor,
                      title: 'ESP32 Tandon Utama',
                      isOnline: false,
                      onCalibrate: () => context.go(AppRoutes.calibrateDevice('esp32-tandon')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF38BDF8),
          foregroundColor: Colors.white,
          elevation: 0,
          onPressed: () => _showPinDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('TAMBAH ALAT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildDeviceTile({
    required bool isDark,
    required Color cardColor,
    required String title,
    required bool isOnline,
    required VoidCallback onCalibrate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: isOnline ? (isDark ? Colors.transparent : Colors.green.withValues(alpha: 0.3)) : Colors.transparent),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF34D399).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.memory_rounded, 
            color: isOnline ? const Color(0xFF34D399) : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          title, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF34D399) : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: isOnline ? [const BoxShadow(color: Color(0xFF34D399), blurRadius: 4)] : [],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'Online' : 'Offline', 
              style: TextStyle(color: isOnline ? const Color(0xFF34D399) : Colors.grey),
            ),
          ],
        ),
        trailing: InkWell(
          onTap: onCalibrate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8)),
          ),
        ),
      ),
    );
  }
}