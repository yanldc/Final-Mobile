import 'package:flutter/material.dart';

class VerDepoisScreen extends StatelessWidget {
  const VerDepoisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Ver Depois',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF560982),
          ),
        ),
      ),
    );
  }
}