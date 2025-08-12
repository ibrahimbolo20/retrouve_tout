import 'package:flutter/material.dart';
import 'package:retrouve_tout/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import 'recherche_intelligente_page.dart';
import 'trusted_community_screen.dart';
import 'precise_location_screen.dart';
import 'login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToMainScreen();
    }
  }

void _goToMainScreen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MainScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
             physics: NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            children: [
              WelcomeScreen(onNext: _nextPage),
              RechercheIntelligentePage(onNext: _nextPage),
              TrustedCommunityScreen(onNext: _nextPage),
              PreciseLocationScreen(onNext: _nextPage),
              LoginScreen(onFinish: _goToMainScreen),
            ],
          ),
          if (_currentPage < 4)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _goToMainScreen,
                child: Text(
                  'Passer',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
