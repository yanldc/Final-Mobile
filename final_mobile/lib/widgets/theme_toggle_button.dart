import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) => IconButton(
        onPressed: controller.toggleTheme,
        icon: Icon(
          controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: controller.isDarkMode ? Colors.white : const Color(0xFF560982),
        ),
      ),
    );
  }
}