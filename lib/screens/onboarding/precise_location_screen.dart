import 'package:flutter/material.dart';
import '../../widgets/onboarding_template.dart';

class PreciseLocationScreen extends StatelessWidget {
  final VoidCallback onNext;

  PreciseLocationScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      backgroundColor: Colors.grey[50]!,
      icon: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(color: Colors.orange[300], shape: BoxShape.circle),
        child: Center(child: Icon(Icons.location_on, size: 60, color: Colors.white)),
      ),
      title: 'Localisation précise',
      description: 'Activez la géolocalisation pour retrouver plus facilement vos objets et aider les autres à les localiser rapidement.',
      features: ['Recherche par proximité', 'Alertes en temps réel'],
      buttonText: 'C\'est parti !',
      buttonColor: Colors.orange,
      onNext: onNext,
    );
  }
}