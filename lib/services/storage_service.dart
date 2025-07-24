import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Télécharger un fichier (par exemple, une image)
  Future<String?> uploadFile(String filePath, String fileName) async {
    try {
      File file = File(filePath);
      Reference storageRef = _storage.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erreur de téléchargement : $e');
      return null;
    }
  }

  // Supprimer un fichier
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference storageRef = _storage.refFromURL(fileUrl);
      await storageRef.delete();
    } catch (e) {
      print('Erreur de suppression : $e');
    }
  }

  // Obtenir l'URL d'un fichier
  Future<String?> getDownloadURL(String filePath) async {
    try {
      Reference storageRef = _storage.ref().child(filePath);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Erreur de récupération de l\'URL : $e');
      return null;
    }
  }
}