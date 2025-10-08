import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const bg = Color(0xFF0F1114);
  const surface = Color(0xFF171A1F);
  const primary = Color(0xFF00FF99);
  const secondary = Color(0xFF7A7F88);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: primary,
      secondary: secondary,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );
}
