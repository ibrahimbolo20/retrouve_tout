import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MesObjetsScreen extends StatelessWidget {
  const MesObjetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes objets")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("Aucun objet ajouté."));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: item['imageUrl'] != null
                    ? Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image),
                title: Text(item['name']),
                subtitle: Text(item['category']),
              );
            },
          );
        },
      ),
    );
  }
}
