import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xff6750A4),
        secondary: Color(0xff625B71),
        tertiary: Color(0xff7D5260),
        error: Color(0xffB3261E),
        background: Color(0xffFFFBFE),
        onSecondary: Color(0xffFFFFFF),
        onTertiary: Color(0xffFFFFFF),
        onBackground: Color(0xff1C1B1F),
        primaryContainer: Color(0xffEADDFF),
        secondaryContainer: Color(0xffE8DEF8),
        tertiaryContainer: Color(0xffFFD8E4),
        errorContainer: Color(0xffF9DEDC),
        surface: Color(0xffFFFBFE),
        surfaceVariant: Color(0xffE7E0EC),
        onPrimaryContainer: Color(0xff21005D),
        onSecondaryContainer: Color(0xff1D192B),
        onTertiaryContainer: Color(0xff31111D),
        onErrorContainer: Color(0xff410E0B),
        onSurface: Color(0xff1C1B1F),
        onSurfaceVariant: Color(0xff49454F),
        outline: Color(0xff79747E),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xffD0BCFF),
        secondary: Color(0xffCCC2DC),
        tertiary: Color(0xffEFB8C8),
        error: Color(0xffF2B8B5),
        background: Color(0xff1C1B1F),
        onPrimary: Color(0xff381E72),
        onSecondary: Color(0xff332D41),
        onTertiary: Color(0xff492532),
        onError: Color(0xff601410),
        onBackground: Color(0xffE6E1E5),
        primaryContainer: Color(0xff4F378B),
        secondaryContainer: Color(0xff4A4458),
        tertiaryContainer: Color(0xff633B48),
        errorContainer: Color(0xff8C1D18),
        surface: Color(0xff1C1B1F),
        surfaceVariant: Color(0xff49454F),
        onPrimaryContainer: Color(0xffEADDFF),
        onSecondaryContainer: Color(0xffE8DEF8),
        onTertiaryContainer: Color(0xffFFD8E4),
        onErrorContainer: Color(0xffF9DEDC),
        onSurface: Color(0xffE6E1E5),
        onSurfaceVariant: Color(0xffCAC4D0),
        outline: Color(0xff938F99),
      ),
    );
  }
}
