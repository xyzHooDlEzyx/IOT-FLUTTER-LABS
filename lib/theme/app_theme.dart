import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    const baseScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1C1E22),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF00B5A5),
      onSecondary: Color(0xFF06201E),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFF4F4F2),
      onSurface: Color(0xFF1B1C1E),
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      colorScheme: baseScheme,
      textTheme: textTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF2F2F0),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF7F7F5),
        border: OutlineInputBorder(),
      ),
    );
  }
}
