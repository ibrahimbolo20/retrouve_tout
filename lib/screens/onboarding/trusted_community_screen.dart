import 'package:flutter/material.dart';

class TrustedCommunityScreen extends StatelessWidget {
  final VoidCallback onNext;

  const TrustedCommunityScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF3FA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Bouton Passer
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: onNext,
                    child: const Text(
                      'Passer',
                      style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Illustration
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB3DAF2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(top: 30, child: _circleAvatar(Colors.blue)),
                        Positioned(bottom: 30, child: _circleAvatar(Colors.orange)),
                        Positioned(left: 30, child: _circleAvatar(Colors.green)),
                        Positioned(right: 30, child: _circleAvatar(Colors.orange)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Titre
                const Text(
                  'Communauté de confiance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Rejoignez une communauté bienveillante où chacun s\'entraide pour retrouver les objets perdus. Profils vérifiés et système de notation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D), height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Fonctionnalités
                _buildFeature(Icons.people, 'Communauté active et solidaire', Color(0xFF2196F3)),
                const SizedBox(height: 12),
                _buildFeature(Icons.verified_user, 'Profils vérifiés et sécurisés', Color(0xFF4CAF50)),

                const Spacer(flex: 2),

                // Indicateurs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(false),
                    const SizedBox(width: 6),
                    _buildDot(true),
                    const SizedBox(width: 6),
                    _buildDot(false),
                  ],
                ),
                const SizedBox(height: 32),

                // Bouton Suivant
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Suivant',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
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
    );
  }

  static Widget _circleAvatar(Color color) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Container(width: 22, height: 22, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ),
    );
  }

  static Widget _buildFeature(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
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
        color: active ? const Color(0xFF2196F3) : const Color(0xFFBDC3C7),
        shape: BoxShape.circle,
      ),
    );
  }
}
