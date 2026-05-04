import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Warm Yellow/Orange (sunrise)
  static const Color primary = Color(0xFFFF9500);
  static const Color primaryLight = Color(0xFFFFB84D);
  static const Color primaryDark = Color(0xFFE07D00);

  // Secondary - Calm Navy/Purple (night)
  static const Color secondary = Color(0xFF2D3A8C);
  static const Color secondaryLight = Color(0xFF4A5BC7);
  static const Color secondaryDark = Color(0xFF1A2460);

  // Accent
  static const Color accent = Color(0xFFFF6B6B);

  // Background
  static const Color background = Color(0xFFF8F6F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EDE5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // League colors
  static const Map<String, Color> leagueColors = {
    'dawn': Color(0xFF8E99A4),    // grey-blue
    'morning': Color(0xFF81C784),  // green
    'noon': Color(0xFFFFD54F),     // yellow
    'sunset': Color(0xFFFF8A65),   // orange
    'star': Color(0xFF7986CB),     // indigo
    'moon': Color(0xFFBA68C8),     // purple
    'sun': Color(0xFFFFB300),      // gold
  };
}
