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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), // Responsive desktop: mirip ukuran mobile
          child: Stack(
            children: [
              // Konten Halaman (Bisa discroll penuh sampai bawah)
              Positioned.fill(
                child: navigationShell,
              ),
              // Bottom Nav Bar (Mengambang di atas)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomTopBar(
                  selectedIndex: navigationShell.currentIndex,
                  onItemTapped: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
