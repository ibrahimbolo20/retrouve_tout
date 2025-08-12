import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/onboarding/onboarding_screen.dart'; // ✅ Import du container Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool hasInternet = await checkInternetConnection();
  runApp(RetrouveToutApp(hasInternet: hasInternet));
}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

class RetrouveToutApp extends StatelessWidget {
  final bool hasInternet;

  const RetrouveToutApp({Key? key, required this.hasInternet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetrouveTout',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: hasInternet
          ? OnboardingScreen() // ✅ Lance la séquence complète si connecté
          : const NoInternetScreen(),
    );
  }
}

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