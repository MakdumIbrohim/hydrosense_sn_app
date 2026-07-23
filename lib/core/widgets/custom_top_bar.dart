import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomTopBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_outlined,
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavBarItem(
              icon: Icons.propane_tank_outlined,
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _NavBarItem(
              icon: Icons.dashboard_outlined,
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
            ),
            _NavBarItem(
              icon: Icons.analytics_outlined,
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            _NavBarItem(
              icon: Icons.settings_outlined,
              isSelected: selectedIndex == 4,
              onTap: () => onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5FF29) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 24.0,
        ),
      ),
    );
  }
}
