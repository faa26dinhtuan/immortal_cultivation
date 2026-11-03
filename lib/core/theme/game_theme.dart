import 'package:flutter/material.dart';

abstract final class GameTheme {
  static const paper = Color(0xfff6f2e6);
  static const ink = Color(0xff202e27);
  static const pine = Color(0xff28483a);
  static const clay = Color(0xff874332);
  static const cream = Color(0xfffff2c9);
  static const pinSize = 48.0;
  static const pinBadgeSize = 24.0;
  static const pinIconSize = 16.0;
  static const contentWidth = 740.0;
  static const gutter = 20.0;

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: pine,
      primary: pine,
      surface: paper,
      onSurface: ink,
    ),
    scaffoldBackgroundColor: paper,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
