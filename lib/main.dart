import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) => MaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFF1976D2),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: OnboardingScreen(),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Bienvenue chez RetrouveTout !',
      'description': 'Retrouvez ce qui compte pour vous.',
      'image': 'assets/welcome_background.png',
    },
    {
      'title': 'Recherche intelligente',
      'description': 'Trouvez rapidement avec des filtres avancés.',
      'image': 'assets/search_background.png',
    },
    {
      'title': 'Communauté de confiance',
      'description': 'Sécurité garantie avec des vérifications.',
      'image': 'assets/community_background.png',
    },
    {
      'title': 'Localisation précise',
      'description': 'Signalez avec une carte interactive.',
      'image': 'assets/location_background.png',
    },
    {
      'title': 'Commencez maintenant !',
      'description': 'Connectez-vous ou inscrivez-vous.',
      'image': 'assets/login_background.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: _onboardingData[index]['title'],
                    description: _onboardingData[index]['description'],
                    image: _onboardingData[index]['image'],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 12.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Color(0xFF1976D2) : Colors.grey,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text('Passer', style: GoogleFonts.poppins(fontSize: 16.sp, color: Color(0xFF1976D2))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? 'Commencer' : 'Suivant',
                      style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  OnboardingPage({required this.title, required this.description, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            description,
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion', style: GoogleFonts.poppins(fontSize: 18.sp))),
      body: Center(child: Text('Écran de connexion (à implémenter)', style: GoogleFonts.poppins(fontSize: 16.sp))),
    );
  }
}