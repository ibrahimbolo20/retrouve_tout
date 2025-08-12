import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:intl/date_symbol_data_local.dart';
import 'package:retrouve_tout/screens/onboarding/login_screen.dart';
import 'package:retrouve_tout/screens/onboarding/splash_screen.dart';
=======
import 'package:connectivity_plus/connectivity_plus.dart';
>>>>>>> 7a2e7c92a506f56219b7662c68ea3d9c573ab4a4
import 'firebase_options.dart';

import 'utils/theme.dart';
// import 'screens/onboarding/onboarding_screen.dart'; // ✅ Import du container Onboarding

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
<<<<<<< HEAD
    await initializeDateFormatting('fr_FR', null);

  
=======
  bool hasInternet = await checkInternetConnection();
  runApp(RetrouveToutApp(hasInternet: hasInternet));
}
>>>>>>> 7a2e7c92a506f56219b7662c68ea3d9c573ab4a4

Future<bool> checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

class RetrouveToutApp extends StatelessWidget {
<<<<<<< HEAD
  const RetrouveToutApp({super.key});
=======
  final bool hasInternet;

  const RetrouveToutApp({Key? key, required this.hasInternet}) : super(key: key);
>>>>>>> 7a2e7c92a506f56219b7662c68ea3d9c573ab4a4

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetrouveTout',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      routes: {
        '/auth': (context) => LoginScreen(onFinish: () {}),
        
      },
    
      home: SplashScreen(), // ✅ Lance la séquence complète
=======
      home: hasInternet
          ? OnboardingScreen() // ✅ Lance la séquence complète si connecté
          : const NoInternetScreen(),
>>>>>>> 7a2e7c92a506f56219b7662c68ea3d9c573ab4a4
    );
  }
}

<<<<<<< HEAD
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
=======
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Aucune connexion Internet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Veuillez vous connecter à Internet pour utiliser l\'application.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool hasInternet = await checkInternetConnection();
                if (hasInternet) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RetrouveToutApp(hasInternet: true)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Toujours pas de connexion Internet.')),
                  );
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 7a2e7c92a506f56219b7662c68ea3d9c573ab4a4
