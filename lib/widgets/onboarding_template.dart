import 'package:flutter/material.dart';

class OnboardingTemplate extends StatelessWidget {
  final Color backgroundColor;
  final Widget icon;
  final String title;
  final String? subtitle;
  final String description;
  final List<String>? features;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onNext;

  // Ajout des paramètres
  final bool showRegisterButton;
  final VoidCallback? onRegister;

  const OnboardingTemplate({super.key, 
    required this.backgroundColor,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.description,
    this.features,
    required this.buttonText,
    required this.buttonColor,
    required this.onNext,
    this.showRegisterButton = false, // Par défaut false
    this.onRegister,                 // Peut être null
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: 50),
          Text(title, style: TextStyle(fontSize: 24, color: Colors.grey[800])),
          if (subtitle != null) ...[
            SizedBox(height: 10),
            Text(subtitle!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
          SizedBox(height: 30),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5)),
          if (features != null) ...[
            SizedBox(height: 40),
            Column(
              children: features!.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: buttonColor, size: 20),
                    SizedBox(width: 15),
                    Text(feature, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              )).toList(),
            ),
          ],
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == 0 ? buttonColor : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            )),
          ),
          SizedBox(height: 100),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: Text(buttonText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),

          // Affiche un bouton d'inscription si demandé
          if (showRegisterButton && onRegister != null) ...[
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onRegister,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  side: BorderSide(color: buttonColor),
                ),
                child: Text('S\'inscrire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: buttonColor)),
              ),
            ),
          ],

          if (buttonText == 'Commencer') ...[
            SizedBox(height: 20),
            Text(
              'En continuant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
