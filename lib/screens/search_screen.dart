import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rechercher'), backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un objet, un lieu, une description',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Tout', 'Électronique', 'Vêtements'].map((cat) => FilterChip(
                    label: Text(cat),
                    selected: false,
                    onSelected: (bool value) {},
                  )).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('iPhone 14 Pro'),
                  subtitle: Text('Perdu près de la station de métro Châtelet'),
                  trailing: Icon(Icons.check, color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}