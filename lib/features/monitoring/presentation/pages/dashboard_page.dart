import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sensor_card_widget.dart';
import '../widgets/chart_widget.dart';

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
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Fetch data update
          await Future.delayed(const Duration(seconds: 1));
        },
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
              const Align(
                alignment: Alignment.centerRight,
                child: Text('Terakhir update: 12:00', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                children: const [
                  SensorCardWidget(title: 'pH Air', value: '6.5', unit: 'pH', icon: Icons.water_drop, statusColor: AppColors.success),
                  SensorCardWidget(title: 'EC Pupuk', value: '1.4', unit: 'mS/cm', icon: Icons.bolt, statusColor: AppColors.success),
                  SensorCardWidget(title: 'Suhu', value: '25.0', unit: '°C', icon: Icons.thermostat, statusColor: AppColors.warning),
                  SensorCardWidget(title: 'Volume', value: '80', unit: 'L', icon: Icons.waves, statusColor: AppColors.success),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Grafik Tren
              const ChartWidget(),
              const SizedBox(height: 32), // Padding bottom
            ],
          ),
        ),
      ),
    );
  }
}