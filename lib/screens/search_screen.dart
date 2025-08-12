import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechercher'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un objet, un lieu, une description',
                prefixIcon: Icon(IconlyLight.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Tout', 'Électronique', 'Vêtements']
                  .map(
                    (cat) => FilterChip(
                      label: Text(cat),
                      selected: false,
                      onSelected: (bool value) {},
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(IconlyLight.call), // Remplace l'icône de téléphone
                  title: Text('iPhone 14 Pro'),
                  subtitle: Text('Perdu près de la station de métro Châtelet'),
                  trailing: Icon(IconlyLight.tickSquare, color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
