import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color.fromARGB(255, 182, 213, 59),
      brightness: Brightness.light,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color.fromARGB(255, 182, 213, 59),
      brightness: Brightness.dark,
    );
  }
}
