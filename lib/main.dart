import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const RetrouveToutApp());
}

class RetrouveToutApp extends StatelessWidget {
  const RetrouveToutApp({Key? key}) : super(key: key);  // <-- Ajout du key ici

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetrouveTout',
      theme: appTheme(),
      home:  OnboardingScreen(), // Si OnboardingScreen est un StatelessWidget, ajoute aussi const ici
      debugShowCheckedModeBanner: false,
    );
  }
}
