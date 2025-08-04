import 'package:flutter/material.dart';
import 'package:retrouve_tout/screens/home_screen.dart';
import 'package:retrouve_tout/screens/search_screen.dart';
import 'package:retrouve_tout/screens/add_item_screen.dart';
import 'package:retrouve_tout/screens/notifications_screen.dart';
import 'package:retrouve_tout/screens/profile_screen.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

enum AddItemType { lost, found }

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    Container(), // Placeholder (page vide) pour l'index 2
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddModal();
      return;
    }
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(IconlyBold.danger, color: Colors.orange),
              title: const Text("Signaler un objet perdu"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddItemScreen(type: AddItemType.lost.name),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(IconlyBold.plus, color: Colors.green),
              title: const Text("Ajouter un objet trouvé"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddItemScreen(type: AddItemType.found.name),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      color: Colors.white,
      height: 70,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(IconlyBold.home, "Accueil", _selectedIndex == 0, () => _onItemTapped(0)),
              _buildNavItem(IconlyBold.search, "Rechercher", _selectedIndex == 1, () => _onItemTapped(1)),
              const SizedBox(width: 60), // Espace réservé au bouton central
              _buildNavItem(IconlyBold.notification, "Notifications", _selectedIndex == 3, () => _onItemTapped(3)),
              _buildNavItem(IconlyBold.profile, "Profil", _selectedIndex == 4, () => _onItemTapped(4)),
            ],
          ),
          // Bouton central +
          Center(
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 32),
                onPressed: () => _onItemTapped(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? Colors.orange : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.orange : Colors.grey,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
