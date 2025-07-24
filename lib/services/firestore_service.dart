import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:retrouve_tout/models/item.dart';

class FirestoreService {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Ajouter un objet
  Future<void> addItem(Item item) async {
    await items.doc(item.id).set(item.toMap());
  }

  // Récupérer les objets
  Stream<List<Item>> getItems() {
    return items.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Mettre à jour un objet
  Future<void> updateItem(Item item) async {
    await items.doc(item.id).update(item.toMap());
  }

  // Supprimer un objet
  Future<void> deleteItem(String id) async {
    await items.doc(id).delete();
  }

  // Ajouter ou mettre à jour les données utilisateur
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot doc = await users.doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }
}