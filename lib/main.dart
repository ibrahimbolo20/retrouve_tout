import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:retrouve_tout/screens/onboarding/splash_screen.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
// import 'screens/onboarding/onboarding_screen.dart'; // ✅ Import du container Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RetrouveToutApp());
}

class RetrouveToutApp extends StatelessWidget {
  const RetrouveToutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetrouveTout',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ Lance la séquence complète
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'utils/theme.dart';
// import 'screens/onboarding/onboarding_screen.dart';
// import 'screens/onboarding/login_screen.dart';
// import 'screens/main_screen.dart'; // ta page d'accueil après connexion
// import 'package:firebase_auth/firebase_auth.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 

//   // Récupère prefs pour vérifier si l’onboarding a été vu
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

//   // Vérifie si utilisateur connecté
//   User? user = FirebaseAuth.instance.currentUser;

//   // Lancement de l'app
//   runApp(RetrouveToutApp(
//     onboardingDone: onboardingDone,
//     isUserLoggedIn: user != null,
//   ));
// }

// class RetrouveToutApp extends StatelessWidget {
//   final bool onboardingDone;
//   final bool isUserLoggedIn;

//   const RetrouveToutApp({
//     Key? key,
//     required this.onboardingDone,
//     required this.isUserLoggedIn,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Widget startPage;

//     if (!onboardingDone) {
//       startPage = OnboardingScreen();
//     } else if (!isUserLoggedIn) {
//       startPage = LoginScreen(
//          onFinish: () {
     
//     // Tu peux ici relancer l'app ou naviguer vers l'écran principal
//     runApp(RetrouveToutApp(
//       onboardingDone: true,
//       isUserLoggedIn: true,
//     ));
//   },
//       ); // ta page de connexion
//     } else {
//       startPage =MainScreen(); // l’utilisateur est déjà connecté
//     }

//     return MaterialApp(
//       title: 'RetrouveTout',
//       theme: appTheme(),
//       debugShowCheckedModeBanner: false,
//       home: startPage,
//     );
//   }
// }
