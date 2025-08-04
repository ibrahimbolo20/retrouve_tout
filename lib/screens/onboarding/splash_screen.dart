import 'package:flutter/material.dart';
import 'package:retrouve_tout/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if(!mounted) return;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      if(!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      if (user != null) {
        if(!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(onFinish: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            );
          })),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:retrouve_tout/screens/main_navigation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:retrouve_tout/screens/onboarding/login_screen.dart';
// import 'package:retrouve_tout/screens/onboarding/onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkFirstLaunch();
//   }

//   Future<void> _checkFirstLaunch() async {
//     // Petit délai pour afficher le splash
//     await Future.delayed(const Duration(seconds: 2));

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

//     if (!mounted) return;

//     if (isFirstTime) {
//       await prefs.setBool('isFirstTime', false);
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//       );
//     } else {
//       // Attendre le bon état de l'utilisateur
//       final user = await FirebaseAuth.instance.authStateChanges().first;

//       if (!mounted) return;

//       if (user != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => MainNavigation()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => LoginScreen(
//               onFinish: () {
//                 if (!mounted) return;
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => MainNavigation()),
//                 );
//               },
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
