// lib/core/theme_controller.dart
import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  // This MUST be a ValueNotifier
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  void toggleTheme() {
    mode.value = mode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
