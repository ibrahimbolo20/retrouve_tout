import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Column(
            children: const [
              SizedBox(height: 20),
              Text(
                "Notifications",
                style: TextStyle(
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Restez informé de l'activité",
                style: TextStyle(
                  color: Color(0xFF8C939E),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Color(0xFFBFC6D1)),
              onPressed: () {},
              tooltip: "Paramètres",
            ),
            SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              color: Color(0xFFEAEAEA),
              height: 1,
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.notifications_none, size: 48, color: Color(0xFF56AFFF)),
              SizedBox(height: 12),
              Text(
                "Aucune notification",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF23262F),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Vous recevez ici les notifications concernant vos objets signalés et les correspondances trouvées.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8C939E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
