import 'package:flutter/material.dart';
import '../widgets/custom_top_bar.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomTopBar(
            selectedIndex: navigationShell.currentIndex,
            onItemTapped: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}
