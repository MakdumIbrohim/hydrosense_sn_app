import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../monitoring/presentation/providers/sensor_provider.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  void _showPinDialog(BuildContext context, String deviceId) {
    final TextEditingController pinController = TextEditingController();
    bool isError = false;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFB923C).withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.lock_rounded, color: Color(0xFFFB923C)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text('Keamanan Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Masukkan PIN admin untuk mengakses mikro kontroler.', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        errorText: isError ? 'PIN salah!' : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('BATAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              if (pinController.text == '123456') {
                                Navigator.pop(context);
                                context.go(AppRoutes.deviceFeatures(deviceId));
                              } else {
                                setState(() => isError = true);
                              }
                            },
                            child: const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                child: Consumer<SensorProvider>(
                  builder: (context, provider, child) {
                    final data = provider.currentData;
                    // Anggap online jika data Firebase ditarik kurang dari 10 detik yang lalu
                    bool isOnline = false;
                    if (data != null) {
                      isOnline = DateTime.now().difference(data.timestamp).inSeconds < 10;
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120.0),
                      children: [
                        _buildDeviceTile(
                          isDark: isDark,
                          cardColor: cardColor,
                          title: 'HydroSense Node 1',
                          isOnline: isOnline,
                          onCalibrate: () => _showPinDialog(context, 'esp32-node-1'),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onCalibrate,
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
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}