import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            children: [
              Text(
                'RetrouveTout',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Retrouvez facilement vos objets perdus',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Icon(Icons.location_on, color: Colors.grey),
            Text('Paris, FR', style: TextStyle(color: Colors.grey)),
            SizedBox(width: 10),
            Icon(Icons.settings, color: Colors.grey),
            SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Section Statistiques
              Row(
                children: [
                  _buildStatCard(Icons.warning, '1', 'Objets perdus', Colors.orange, Colors.orange.shade200),
                  SizedBox(width: 16),
                  _buildStatCard(Icons.check_circle, '2', 'Objets trouvés', Colors.green, Colors.green.shade200),
                ],
              ),
              SizedBox(height: 16),

              // ✅ Badges Section
              _buildBadgeSection(),

              SizedBox(height: 16),

              // ✅ Activité récente
              _buildRecentActivity(),

              SizedBox(height: 16),

              // ✅ Statistiques Communauté
              _buildCommunityStats(),

              SizedBox(height: 16),

              // ✅ Villes actives
              _buildActiveCities(),

              SizedBox(height: 16),

              // ✅ Succès récents
              _buildSuccessSection(),

              SizedBox(height: 16),

              // ✅ Message encouragement
              _buildMotivationCard(),

              SizedBox(height: 80), // espace pour navigation
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Widget Statistique
  Widget _buildStatCard(IconData icon, String value, String label, Color color, Color borderColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget Badges
  Widget _buildBadgeSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.orange),
          SizedBox(width: 8),
          Text('3 badges'),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: Text('Niv 2'),
          ),
        ],
      ),
    );
  }

  // 🔹 Widget Activité récente
  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange),
              SizedBox(width: 8),
              Text('Activité récente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 8),
          Text('0 nouveaux objets signalés aujourd\'hui', style: TextStyle(color: Colors.grey[600])),
          Align(alignment: Alignment.centerRight, child: Text('+0', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  // 🔹 Widget Statistiques Communauté
  Widget _buildCommunityStats() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.orange),
              SizedBox(width: 8),
              Text('Statistiques de la communauté', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildCommunityStat('15 420', 'Utilisateurs inscrits', Colors.blue),
              _buildCommunityStat('2 847', 'Objets retrouvés', Colors.green),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildCommunityStat('342', 'Actifs aujourd\'hui', Colors.orange),
              _buildCommunityStat('73 %', 'Taux de succès', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  // 🔹 Widget Villes actives
  Widget _buildActiveCities() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.blue),
              SizedBox(width: 8),
              Text('Les villes les plus actives', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 16),
          _buildCityItem('1', 'Paris', '1205 objets'),
          _buildCityItem('2', 'Lyon', '523 objets'),
          _buildCityItem('3', 'Marseille', '412 objets'),
        ],
      ),
    );
  }

  Widget _buildCityItem(String rank, String city, String count) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.blue.shade100,
            child: Text(rank, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(city, style: TextStyle(fontWeight: FontWeight.w500))),
          Text(count, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // 🔹 Widget Succès récents
  Widget _buildSuccessSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.celebration, color: Colors.green),
              SizedBox(width: 8),
              Text('Succès récents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 16),
          _buildSuccessItem('iPhone 13 Pro', 'Gare du Nord', 'Il y a 2h', Icons.phone_iphone),
          _buildSuccessItem('Portefeuille en cuir', 'Métro Châtelet', 'Il y a 3h', Icons.account_balance_wallet),
          _buildSuccessItem('Clés de voiture', 'Parc Monceau', 'Il y a 8h', Icons.key),
        ],
      ),
    );
  }

  Widget _buildSuccessItem(String item, String location, String time, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.green, child: Icon(icon, color: Colors.white, size: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                child: Text('Retrouvé', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Widget Motivation
  Widget _buildMotivationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.green.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: Colors.orange, size: 30),
          SizedBox(height: 8),
          Text('Ensemble, on retrouve tout !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Rejoignez les 342 personnes qui répondent aujourd\'hui', style: TextStyle(color: Colors.grey[700]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
