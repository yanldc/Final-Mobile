import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'isDarkMode';
  late Box _box;
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _initTheme();
  }

  Future<void> _initTheme() async {
    _box = await Hive.openBox('theme');
    _isDarkMode.value = _box.get(_themeKey, defaultValue: false);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _box.put(_themeKey, _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xFF560982),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF560982),
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: const Color(0xFF560982),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF560982),
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}