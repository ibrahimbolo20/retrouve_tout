import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class RechercheIntelligentePage extends StatelessWidget {
  final VoidCallback onNext;

  const RechercheIntelligentePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    print('RechercheIntelligentePage build appelé');
    bool isTapped = false;

    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F6F3), Color(0xFFF5FFFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16), // Remplacement de l'espace occupé par le bouton "Passer"
                    const Spacer(flex: 2),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFF36D3A0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A36D3A0),
                            blurRadius: 32,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF36D3A0),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    width: 18,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF36D3A0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            right: 38,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                IconlyLight.search,
                                size: 20,
                                color: Color(0xFF36D3A0),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 56,
                            left: 48,
                            child: Container(
                              width: 26,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A574),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            left: 38,
                            child: Container(
                              width: 36,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A574),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 54,
                            child: Container(
                              width: 24,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E86AB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 26,
                            child: Container(
                              width: 22,
                              height: 13,
                              decoration: const BoxDecoration(
                                color: Color(0xFF36D3A0),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      'Recherche intelligente',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2D36),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Utilisez notre système de recherche avancé avec filtres par catégorie, lieu et date pour trouver rapidement vos objets perdus.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7F8C8D),
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true),
                        const SizedBox(width: 8),
                        _buildDot(false),
                        const SizedBox(width: 8),
                        _buildDot(false),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
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
                          backgroundColor: const Color(0xFF36D3A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0x1A36D3A0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Suivant',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              IconlyLight.arrowRight,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDot(bool active) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF36D3A0) : const Color(0xFFBDC3C7),
        shape: BoxShape.circle,
      ),
    );
  }
}