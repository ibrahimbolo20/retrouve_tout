import 'package:flutter/material.dart';
import '../../widgets/onboarding_template.dart';

class IntelligentSearchScreen extends StatelessWidget {
  final VoidCallback onNext;

  IntelligentSearchScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      backgroundColor: Colors.grey[50]!,
      icon: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(color: Colors.green[300], shape: BoxShape.circle),
        child: Center(child: Icon(Icons.search, size: 60, color: Colors.white)),
      ),
      title: 'Recherche intelligente',
      description: 'Utilisez notre système de recherche avancé avec filtres par catégorie, lieu et date pour trouver rapidement vos objets perdus.',
      buttonText: 'Suivant',
      buttonColor: Colors.green,
      onNext: onNext,
    );
  }
}