import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sensor_card_widget.dart';
import '../widgets/chart_widget.dart';
import '../providers/sensor_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SensorProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = provider.currentData;
          if (data == null) {
            return const Center(child: Text('Tidak ada data sensor.'));
          }

          return RefreshIndicator(
            onRefresh: provider.refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Status Utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kondisi Normal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success)),
                              Text('Semua parameter dalam batas aman', style: TextStyle(color: AppColors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 3. Waktu Sinkronisasi
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Terakhir update: ${DateFormat('HH:mm:ss').format(data.timestamp)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 24),

                  // 1. Grid Kartu Sensor
                  const Text('Data Sensor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      SensorCardWidget(title: 'pH Air', value: data.ph.toStringAsFixed(1), unit: 'pH', icon: Icons.water_drop, statusColor: AppColors.success),
                      SensorCardWidget(title: 'EC Pupuk', value: data.ec.toStringAsFixed(2), unit: 'mS/cm', icon: Icons.bolt, statusColor: AppColors.success),
                      SensorCardWidget(title: 'TDS', value: data.tds.toStringAsFixed(0), unit: 'ppm', icon: Icons.science, statusColor: AppColors.success),
                      SensorCardWidget(title: 'Suhu Air', value: data.waterTemperature.toStringAsFixed(1), unit: '°C', icon: Icons.thermostat, statusColor: AppColors.warning),
                      SensorCardWidget(title: 'Volume', value: data.waterVolume.toStringAsFixed(1), unit: 'L', icon: Icons.waves, statusColor: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Grafik Tren
                  const ChartWidget(),
                  const SizedBox(height: 32), // Padding bottom
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}