import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class PreciseLocationScreen extends StatelessWidget {
  final VoidCallback onNext;

  const PreciseLocationScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    print('PreciseLocationScreen build appelé');
    bool isTapped = false;

    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFEEFE6), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16), // Remplacement de l'espace occupé par le bouton "Passer"
                  const Spacer(flex: 2),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB366),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 110,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                for (var i = 1; i <= 3; i++)
                                  Positioned(
                                    top: i * 20,
                                    left: 10,
                                    right: 10,
                                    child: Container(
                                      height: 1,
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                const Positioned(
                                  top: 25,
                                  left: 25,
                                  child: CircleAvatar(radius: 6, backgroundColor: Color(0xFFFF6B35)),
                                ),
                                const Positioned(
                                  top: 45,
                                  left: 55,
                                  child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF2196F3)),
                                ),
                                const Positioned(
                                  top: 65,
                                  left: 75,
                                  child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF4CAF50)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 25,
                          right: 25,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                              IconlyLight.timeCircle,
                              color: Color(0xFFFF6B35),
                              size: 20,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 25,
                          left: 25,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                              IconlyLight.location,
                              color: Color(0xFFFF6B35),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Localisation précise',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Activez la géolocalisation pour retrouver plus facilement vos objets et aider les autres à les localiser rapidement.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFeature(IconlyLight.discovery, 'Recherche par proximité'),
                  const SizedBox(height: 12),
                  _buildFeature(IconlyLight.notification, 'Alertes en temps réel'),
                  const Spacer(flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 6),
                      _buildDot(false),
                      const SizedBox(width: 6),
                      _buildDot(true),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isTapped) {
                          isTapped = true;
                          print('Suivant cliqué');
                          onNext();
                          Future.delayed(const Duration(milliseconds: 500), () => isTapped = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'C\'est parti !',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            IconlyLight.arrowRight,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50))),
      ],
    );
  }

  static Widget _buildDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF6B35) : const Color(0xFFBDC3C7),
        shape: BoxShape.circle,
      ),
    );
  }
}