import 'package:go_router/go_router.dart';

import '../layout/main_layout.dart';
import '../../features/devices/presentation/pages/add_device_page.dart';
import '../../features/devices/presentation/pages/calibrate_page.dart';
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/monitoring/presentation/pages/dashboard_page.dart';
import '../../features/monitoring/presentation/pages/graph_history_page.dart'; // Import baru
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/tentang_kami_page.dart';
import '../../features/settings/presentation/pages/panduan_penggunaan_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart'; // Diganti ke splash screen

import '../../features/devices/presentation/pages/menu_page.dart';
import '../../features/devices/presentation/pages/device_features_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String dashboard = '/';
  static const String graphHistory = '/graphs';
  static const String menu = '/menu';
  static const String settings = '/settings';
  static const String tentangKami = '/settings/tentang-kami';
  static const String panduanPenggunaan = '/settings/panduan';
  static const String helpSupport = '/settings/help';
  static const String wifiSetup = '/settings/wifi-setup';
  static const String devices = '/devices';
  static const String addDevice = '/menu/add';
  static String deviceFeatures(String id) => '/devices/$id';
  static String calibrateDevice(String id) => '/devices/$id/calibrate';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash, // Menjadi splash pertama kali
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // 0: Menu (Grid 2 - WiFi Config, Auto Watering)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.menu,
                builder: (context, state) => const MenuPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddDevicePage(),
                  ),
                ],
              ),
            ],
          ),
          // 1: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
                routes: [
                  GoRoute(
                    path: 'graphs',
                    builder: (context, state) => const GraphHistoryPage(),
                  ),
                ],
              ),
            ],
          ),
          // 2: Devices / Alat Utama
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.devices,
                builder: (context, state) => const DeviceListPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DeviceFeaturesPage(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'calibrate',
                        builder: (context, state) => CalibratePage(id: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpSupportPage(),
                  ),
                  GoRoute(
                    path: 'tentang-kami',
                    builder: (context, state) => const TentangKamiPage(),
                  ),
                  GoRoute(
                    path: 'panduan',
                    builder: (context, state) => const PanduanPenggunaanPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
