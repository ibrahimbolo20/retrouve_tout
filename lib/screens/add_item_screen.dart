import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({Key? key}) : super(key: key);  // constructeur const avec key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un objet'), // const ici
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),  // const ici
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Nom de l\'objet'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Lieu'),
            ),
            const SizedBox(height: 20), // const ici
            ElevatedButton(
              onPressed: () {},
              child: const Text('Soumettre'),  // const ici
            ),
          ],
        ),
      ),
    );
  }
}
