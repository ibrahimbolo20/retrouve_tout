import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/onboarding/onboarding_screen.dart'; // ✅ Import du container Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RetrouveToutApp());
}

class RetrouveToutApp extends StatelessWidget {
  const RetrouveToutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetrouveTout',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(), // ✅ Lance la séquence complète
    );
  }
}
