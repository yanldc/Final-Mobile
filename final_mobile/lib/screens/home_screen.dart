import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_navbar.dart';
import '../controllers/theme_controller.dart';
import '../widgets/theme_toggle_button.dart';
import 'favoritos_screen.dart';
import 'minhas_cartas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _getScreens(ThemeController themeController) => [
    Center(
      child: Text(
        'Tela Inicial',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: themeController.isDarkMode ? Colors.white : const Color(0xFF560982),
        ),
      ),
    ),
    const FavoritosScreen(),
    const MinhasCartasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: const [ThemeToggleButton()],
        ),
        body: _getScreens(themeController)[_currentIndex],
        bottomNavigationBar: CustomNavbar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}