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
      // Example of hard coded custom color scheme for a theme. In this case, the light theme.
      // colorScheme: const ColorScheme.light(
      //   primary: Color(0xff6750A4),
      //   secondary: Color(0xff625B71),
      //   tertiary: Color(0xff7D5260),
      //   error: Color(0xffB3261E),
      //   background: Color(0xffFFFBFE),
      //   onSecondary: Color(0xffFFFFFF),
      //   onTertiary: Color(0xffFFFFFF),
      //   onBackground: Color(0xff1C1B1F),
      //   primaryContainer: Color(0xffEADDFF),
      //   secondaryContainer: Color(0xffE8DEF8),
      //   tertiaryContainer: Color(0xffFFD8E4),
      //   errorContainer: Color(0xffF9DEDC),
      //   surface: Color(0xffFFFBFE),
      //   surfaceVariant: Color(0xffE7E0EC),
      //   onPrimaryContainer: Color(0xff21005D),
      //   onSecondaryContainer: Color(0xff1D192B),
      //   onTertiaryContainer: Color(0xff31111D),
      //   onErrorContainer: Color(0xff410E0B),
      //   onSurface: Color(0xff1C1B1F),
      //   onSurfaceVariant: Color(0xff49454F),
      //   outline: Color(0xff79747E),
      // ),
