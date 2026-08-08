import "../../../../core/widgets/neumorphic_container.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sensor_card_widget.dart';
import '../widgets/chart_widget.dart';
import '../widgets/skeleton_widget.dart';
import '../providers/sensor_provider.dart';
import '../../../../core/services/update_service.dart'; // Import service update

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.neumoBgDark : AppColors.neumoBg,
      body: SafeArea(
        child: Consumer<SensorProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.currentData == null) {
              return _buildSkeletonLoading(isDark, provider.connectionMessage);
            }

            final data = provider.currentData;
            if (data == null) {
              return const Center(child: Text("Tidak ada data."));
            }

            // Hitung status online (jika lebih dari 10 detik tidak ada data = offline)
            final bool isOnline = DateTime.now().difference(data.timestamp).inSeconds < 10;

            return RefreshIndicator(
              onRefresh: () => provider.refreshData(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ALA BLYNK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HydroSense',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.greenAccent : Colors.redAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: isOnline ? Colors.greenAccent : Colors.redAccent, blurRadius: 6, spreadRadius: 1)],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOnline 
                                      ? 'Online • Update: ${DateFormat('HH:mm:ss').format(data.timestamp)}'
                                      : 'Offline • Terakhir: ${DateFormat('HH:mm:ss').format(data.timestamp)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.wifi_rounded, 
                                  size: 18, 
                                  color: isOnline ? const Color(0xFF34D399) : Colors.grey.shade500
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  data.wifiSsid.isNotEmpty ? data.wifiSsid : 'Tidak diketahui',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isOnline ? const Color(0xFF34D399) : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                            onPressed: () => context.read<SensorProvider>().refreshData(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- GRID GAUGE SENSOR ---
                    Text(
                      'PARAMETER UTAMA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95, // Disesuaikan agar muat dengan gauge
                      children: [
                        SensorCardWidget(title: 'pH Air', value: data.ph.toStringAsFixed(2), unit: 'pH', min: 0, max: 14, color: const Color(0xFF38BDF8)), // Light Blue
                        SensorCardWidget(title: 'EC', value: data.ec.toStringAsFixed(2), unit: 'mS/cm', min: 0, max: 5, color: const Color(0xFF34D399)), // Emerald Green
                        SensorCardWidget(title: 'TDS', value: data.tds.toStringAsFixed(0), unit: 'ppm', min: 0, max: 2000, color: const Color(0xFFA78BFA)), // Purple
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0.4,
                              child: SensorCardWidget(
                                title: 'Suhu Air', 
                                value: data.waterTemperature.toStringAsFixed(1), 
                                unit: '°C', 
                                min: 0, 
                                max: 50, 
                                color: const Color(0xFFFB923C),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.construction_rounded, color: Colors.orange, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'MAINTENANCE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- GRAFIK TREN ---
                    Text(
                      'ANALISIS DATA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      ),
                    ),
                    ChartWidget(
                      history: provider.ecHistory,
                      title: 'EC (Electrical Conductivity)',
                      unit: 'mS/cm',
                      icon: Icons.show_chart_rounded,
                      colors: const [Color(0xFF38BDF8), Color(0xFF34D399)],
                    ),
                    const SizedBox(height: 16),
                    NeumorphicContainer(
                      borderRadius: 16,
                      child: InkWell(
                        onTap: () => context.push('/graphs'),
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_rounded, color: Color(0xFF1F837B)),
                              SizedBox(width: 8),
                              Text(
                                'Lihat Semua Grafik Riwayat Sensor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F837B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDark, String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonWidget(width: 180, height: 32, borderRadius: 8),
                  const SizedBox(height: 8),
                  const SkeletonWidget(width: 220, height: 16, borderRadius: 4),
                  const SizedBox(height: 4),
                  const SkeletonWidget(width: 150, height: 16, borderRadius: 4),
                ],
              ),
              const SkeletonWidget(width: 48, height: 48, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16, height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8))
                  ),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonWidget(width: 130, height: 14, borderRadius: 4),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
            children: List.generate(4, (index) => const SkeletonWidget(width: double.infinity, height: 160, borderRadius: 20)),
          ),
          const SizedBox(height: 32),
          const SkeletonWidget(width: 130, height: 14, borderRadius: 4),
          const SizedBox(height: 16),
          const SkeletonWidget(width: double.infinity, height: 260, borderRadius: 20),
        ],
      ),
    );
  }
}