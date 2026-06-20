import 'package:flutter/material.dart';

class AppColors {
  static const darkBg = Color(0xFF0A0E1A);
  static const darkCard = Color(0xFF1C2236);
  static const accent = Color(0xFF1A56DB);

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? const Color(0xFFF5F5F5) : darkBg;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.white : darkCard;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : darkBg;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white54;
}
