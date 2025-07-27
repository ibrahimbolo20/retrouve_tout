import 'package:flutter/material.dart';

class NextOnboardingScreen extends StatelessWidget {
  const NextOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Écran d\'onboarding suivant',
              style: TextStyle(fontSize: 24, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique pour l'écran suivant ou retour
                Navigator.pop(context); // Exemple : revenir en arrière
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retour',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}