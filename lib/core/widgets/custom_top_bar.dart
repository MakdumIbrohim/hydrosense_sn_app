import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), 
          child: NeumorphicContainer(
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            borderRadius: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.grid_view_rounded,
                  isSelected: selectedIndex == 0,
                  isDark: isDark,
                  onTap: () => onItemTapped(0),
                ),
                _NavBarItem(
                  icon: Icons.speed_rounded,
                  isSelected: selectedIndex == 1,
                  isDark: isDark,
                  onTap: () => onItemTapped(1),
                ),
                _NavBarItem(
                  icon: Icons.memory_rounded,
                  isSelected: selectedIndex == 2,
                  isDark: isDark,
                  onTap: () => onItemTapped(2),
                ),
                _NavBarItem(
                  icon: Icons.settings_outlined,
                  isSelected: selectedIndex == 3,
                  isDark: isDark,
                  onTap: () => onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? const Color(0xFF38BDF8) 
              : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
          size: 28.0,
        ),
      ),
    );
  }
}
