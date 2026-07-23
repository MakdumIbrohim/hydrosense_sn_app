import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  static const Color primary = Color(0xFF009688); // Teal
  static const Color primaryDark = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFFB2DFDB);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Color error = Color(0xFFF44336); // Bahaya, pH/EC buruk
  static const Color warning = Color(0xFFFFC107); // Peringatan
  static const Color success = Color(0xFF4CAF50); // Normal/Optimal
}