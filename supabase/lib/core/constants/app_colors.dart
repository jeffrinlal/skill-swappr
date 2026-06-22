import 'package:flutter/material.dart';

/// App brand colors. Change [primary] to re-brand the whole app.
class AppColors {
  AppColors._();

  // BRAND - modern indigo/violet
  static const Color primary = Color(0xFF5B5BD6);
  static const Color primaryDark = Color(0xFF4747B3);
  static const Color primaryLight = Color(0xFFEAEAFB);

  // Accent (highlights, credits)
  static const Color accent = Color(0xFF14B8A6);

  // NEUTRALS
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color border = Color(0xFFE3E3ED);

  // STATUS
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
