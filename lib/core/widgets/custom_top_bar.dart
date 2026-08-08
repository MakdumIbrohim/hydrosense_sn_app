import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class CustomTopBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Axis axis;

  const CustomTopBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isHorizontal = axis == Axis.horizontal;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isHorizontal ? 400 : 100,
        maxHeight: isHorizontal ? 100 : 400,
      ), 
        child: NeumorphicContainer(
          margin: EdgeInsets.only(
            left: isHorizontal ? 24 : 12, 
            right: isHorizontal ? 24 : 12, 
            bottom: isHorizontal ? 24 : 0, 
            top: isHorizontal ? 8 : 24,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isHorizontal ? 16.0 : 6.0, 
            vertical: isHorizontal ? 6.0 : 16.0,
          ),
          borderRadius: 40.0,
          child: Flex(
            direction: axis,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- DRAG HANDLE INDICATOR ---
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isHorizontal ? 4.0 : 0.0,
                  vertical: isHorizontal ? 0.0 : 4.0,
                ),
                width: isHorizontal ? 4 : 24,
                height: isHorizontal ? 24 : 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (isHorizontal) const SizedBox(width: 4) else const SizedBox(height: 4),
              // --- END INDICATOR ---
              
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
