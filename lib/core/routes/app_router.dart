
import 'package:go_router/go_router.dart';

import '../layout/main_layout.dart';
import '../../features/devices/presentation/pages/add_device_page.dart';
import '../../features/devices/presentation/pages/calibrate_page.dart';
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/monitoring/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String settings = '/settings';
  static const String devices = '/devices';
  static const String addDevice = '/devices/add';
  static String calibrateDevice(String id) => '/devices/$id/calibrate';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // 0: Devices (Tank Icon)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.devices,
                builder: (context, state) => const DeviceListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddDevicePage(),
                  ),
                  GoRoute(
                    path: ':id/calibrate',
                    builder: (context, state) => CalibratePage(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          // 1: Dashboard (Dashboard Icon)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // 2: Settings (Gear Icon)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
