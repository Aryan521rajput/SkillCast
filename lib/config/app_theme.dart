import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// --------------------------------------------------------
  /// COLORS
  /// --------------------------------------------------------
  static const Color lightPrimary = Color(0xFF5B7FFF);
  static const Color darkPrimary = Color(0xFF9BB2FF);

  static const Color lightBG = Color(0xFFF4F6FB);
  static const Color darkBG = Color(0xFF1C1C1E);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF2C2C2E);

  /// --------------------------------------------------------
  /// LIGHT THEME (Material)
  /// --------------------------------------------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
    fontFamily: "Inter",

    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary,
      surface: surfaceLight,
      background: lightBG,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBG,
      elevation: 0,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: "Inter",
      ),
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: lightPrimary, width: 2),
      ),
    ),
  );

  /// --------------------------------------------------------
  /// DARK THEME (Material)
  /// --------------------------------------------------------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
    fontFamily: "Roboto",

    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkPrimary,
      surface: surfaceDark,
      background: darkBG,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkBG,
      elevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: "Roboto",
      ),
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.5),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: darkPrimary, width: 2),
      ),
    ),
  );

  /// --------------------------------------------------------
  /// CUPERTINO (auto-adapts to Material theme)
  /// --------------------------------------------------------
  static CupertinoThemeData cupertinoTheme(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: dark ? darkPrimary : lightPrimary,
      scaffoldBackgroundColor: dark ? darkBG : lightBG,
      barBackgroundColor: dark ? surfaceDark : surfaceLight,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 16,
          fontFamily: dark ? "Roboto" : "Inter",
          color: dark ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );
  }
}
