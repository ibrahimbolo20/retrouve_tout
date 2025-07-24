import 'package:flutter/material.dart';
import '../../widgets/onboarding_template.dart';
import 'onboarding/login_screen.dart'; // si tu veux utiliser celui dans /onboarding

import 'search_screen.dart';


class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  WelcomeScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      backgroundColor: Colors.grey[50]!,
      icon: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Remplacement de withOpacity
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(child: Icon(Icons.search, size: 50, color: Colors.orange)),
      ),
      title: 'Bienvenue sur',
      subtitle: 'RetrouveTout',
      description: 'L\'application qui vous aide à retrouver vos objets perdus et à rendre ceux que vous trouvez',
      features: [
        'Signalez vos objets perdus',
        'Aidez d\'autres à retrouver leurs affaires',
        'Communauté de confiance',
      ],
      buttonText: 'Commencer',
      buttonColor: Colors.orange,
      onNext: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Choisir une action'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Rechercher un objet'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('S\'inscrire/Se connecter'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}