import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2A9D8F);
  static const Color secondary = Color(0xFF264653);
  static const Color background = Color(0xFFF8F9FA);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A9D8F), Color(0xFF1D7A6F)],
  );
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Color(0xFF6C757D),
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}