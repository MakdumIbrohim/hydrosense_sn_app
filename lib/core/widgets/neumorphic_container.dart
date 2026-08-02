import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isPressed;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.neumoBgDark : AppColors.neumoBg;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Inset shadow simulation (biasanya dibuat dengan Gradient di Flutter murni, tapi shadow kosong untuk fallback rata)
                BoxShadow(
                  color: isDark ? AppColors.neumoShadowDarkDark : AppColors.neumoShadowDark,
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark ? AppColors.neumoShadowLightDark : AppColors.neumoShadowLight,
                  offset: const Offset(-4, -4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark ? AppColors.neumoShadowDarkDark : AppColors.neumoShadowDark,
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}
