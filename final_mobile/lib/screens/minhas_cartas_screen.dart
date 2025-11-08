import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class MinhasCartasScreen extends StatelessWidget {
  const MinhasCartasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.isDarkMode ? Colors.black : Colors.white,
        body: Center(
          child: Text(
            'Minhas Cartas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeController.isDarkMode ? Colors.white : const Color(0xFF560982),
            ),
          ),
        ),
      ),
    );
  }
}