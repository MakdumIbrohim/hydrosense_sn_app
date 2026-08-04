import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../widgets/chart_widget.dart';

class GraphHistoryPage extends StatelessWidget {
  const GraphHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Riwayat Grafik Sensor', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            children: [
              ChartWidget(
                history: provider.ecHistory,
                title: 'Tren Nutrisi (EC)',
                unit: 'mS/cm',
                icon: Icons.show_chart_rounded,
                colors: const [Color(0xFF38BDF8), Color(0xFF34D399)],
              ),
              const SizedBox(height: 24),
              ChartWidget(
                history: provider.phHistory,
                title: 'Tren Keasaman (pH)',
                unit: 'pH',
                icon: Icons.science_rounded,
                colors: const [Color(0xFF8B5CF6), Color(0xFFF43F5E)],
              ),
              const SizedBox(height: 24),
              ChartWidget(
                history: provider.tdsHistory,
                title: 'Tren Partikel (TDS)',
                unit: 'ppm',
                icon: Icons.water_drop_rounded,
                colors: const [Color(0xFFFBBF24), Color(0xFFFB923C)],
              ),
              const SizedBox(height: 24),
              ChartWidget(
                history: provider.tempHistory,
                title: 'Tren Suhu Air',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                colors: const [Color(0xFFEF4444), Color(0xFFF59E0B)],
              ),
              const SizedBox(height: 48), // Padding bottom
            ],
          );
        },
      ),
    );
  }
}
