import 'package:flutter/material.dart';
import '../widgets/custom_top_bar.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), // Responsive desktop: mirip ukuran mobile
          child: Column(
            children: [
              Expanded(
                child: navigationShell,
              ),
              CustomTopBar(
                selectedIndex: navigationShell.currentIndex,
                onItemTapped: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
