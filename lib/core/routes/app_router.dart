

import 'package:go_router/go_router.dart';

import '../../features/devices/presentation/pages/add_device_page.dart';
import '../../features/devices/presentation/pages/calibrate_page.dart';
import '../../features/devices/presentation/pages/device_list_page.dart';
import '../../features/monitoring/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/devices',
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
  );
}