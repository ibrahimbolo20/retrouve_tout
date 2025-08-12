import 'package:flutter/material.dart';
import 'package:retrouve_tout/screens/main_screen.dart';
import 'package:retrouve_tout/screens/onboarding/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _realTimeAlerts = false;
  bool _proximitySearch = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFE2E8F0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                color: const Color(0xFF2AA6B0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.location_on, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Localisation',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2AA6B0),
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Activez la géolocalisation pour des recherches plus précises et des alertes de proximité',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 200,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                gradient: const LinearGradient(
                  begin: Alignment(0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: [Color(0xFFC8E6C9), Color(0xFFE8F5E8)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF4CAF50),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 48,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF2196F3),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    bottom: 40,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFFF9800),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 28,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFE91E63),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  const Center(child: Icon(Icons.map, size: 48, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionTile(
              title: 'Alertes en temps réel',
              value: _realTimeAlerts,
              onChanged: (value) => setState(() => _realTimeAlerts = value),
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              title: 'Recherche par proximité',
              value: _proximitySearch,
              onChanged: (value) => setState(() => _proximitySearch = value),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
    onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);

  // Redirige simplement vers la page de connexion
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen(onFinish: () {})),
  );
},


              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2AA6B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'C\'est parti !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2AA6B0),
          ),
        ],
      ),
    );
  }
}