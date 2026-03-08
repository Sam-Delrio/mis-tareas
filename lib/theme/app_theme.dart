// lib/theme/app_theme.dart
// Solo constantes de colores fijos. NO referencia AppColorPalette aquí.

import 'package:flutter/material.dart';

class AppTheme {
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color teal400    = Color(0xFF2DD4BF);
  static const Color amber400   = Color(0xFFFBBF24);
  static const Color orange400  = Color(0xFFFB923C);
  static const Color red500     = Color(0xFFEF4444);

  static const LinearGradient completedGradient =
      LinearGradient(colors: [emerald400, teal400]);
  static const LinearGradient pendingGradient =
      LinearGradient(colors: [amber400, orange400]);
}
