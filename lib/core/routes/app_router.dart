import 'package:go_router/go_router.dart';

import '../layout/main_layout.dart';
import '../../features/devices/presentation/pages/add_device_page.dart';
import '../../features/devices/presentation/pages/calibrate_page.dart';
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/monitoring/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/tentang_kami_page.dart';
import '../../features/settings/presentation/pages/panduan_penggunaan_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

import '../../features/devices/presentation/pages/menu_page.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/';
  static const String menu = '/menu';
  static const String settings = '/settings';
  static const String tentangKami = '/settings/tentang-kami';
  static const String panduanPenggunaan = '/settings/panduan';
  static const String helpSupport = '/settings/help';
  static const String wifiSetup = '/settings/wifi-setup';
  static const String devices = '/devices';
  static const String addDevice = '/menu/add';
  static String calibrateDevice(String id) => '/devices/$id/calibrate';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
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
                    path: ':id/calibrate',
                    builder: (context, state) => CalibratePage(id: state.pathParameters['id']!),
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
