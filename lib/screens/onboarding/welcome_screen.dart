import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeScreen({required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    print('WelcomeScreen build appelé'); // Log pour diagnostiquer les reconstructions
    bool isTapped = false; // Prévenir les taps multiples

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF2EC), Color(0xFFE8F6F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Optimisation du défilement
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo circulaire
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          IconlyLight.bag,
                          color: Color(0xFFFF7F00),
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Texte titre
                    const Text(
                      'Bienvenue sur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'RetrouveTout',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF7F00),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "L'application qui vous aide à retrouver vos objets perdus et à rendre ceux que vous trouvez",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Liste des fonctionnalités
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureItem(
                          IconlyLight.upload,
                          const Color(0xFFFF7F00),
                          'Signalez vos objets perdus',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          IconlyLight.heart,
                          const Color(0xFF4ECDC4),
                          'Aidez d\'autres à retrouver leurs affaires',
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          IconlyLight.profile,
                          const Color(0xFF2E86AB),
                          'Communauté de confiance',
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),

                    // Bouton Commencer
                    SizedBox(
                      width: 280,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isTapped) {
                            isTapped = true;
                            print('Bouton Commencer cliqué');
                            onNext();
                            Future.delayed(const Duration(milliseconds: 500), () {
                              isTapped = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Conditions
                    const Text(
                      "En continuant, vous acceptez nos conditions d'utilisation et\nnotre politique de confidentialité",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}