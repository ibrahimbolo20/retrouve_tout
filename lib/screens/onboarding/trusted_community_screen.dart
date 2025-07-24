import 'package:flutter/material.dart';
import '../../widgets/onboarding_template.dart';

class TrustedCommunityScreen extends StatelessWidget {
  final VoidCallback onNext;

  TrustedCommunityScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      backgroundColor: Colors.grey[50]!,
      icon: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(color: Colors.blue[300], shape: BoxShape.circle),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: 'Communauté de confiance',
      description: 'Rejoignez une communauté bienveillante où chacun s\'entraide pour retrouver les objets perdus. Profils vérifiés et système de notation.',
      features: ['Communauté active et solidaire', 'Profils vérifiés et sécurisés'],
      buttonText: 'Suivant',
      buttonColor: Colors.blue,
      onNext: onNext,
    );
  }
}