import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color.fromARGB(255, 182, 213, 59),
      brightness: Brightness.light,
      fontFamily: GoogleFonts.redHatText().fontFamily,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color.fromARGB(255, 47, 53, 39),
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.redHatText().fontFamily,
    );
  }
}
