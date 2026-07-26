import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../monitoring/presentation/providers/sensor_provider.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

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
                          onCalibrate: () => context.go(AppRoutes.calibrateDevice('esp32-node-1')),
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
      ),
    );
  }
}