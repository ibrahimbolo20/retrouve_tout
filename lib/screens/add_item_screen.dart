import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'perdu';
  DateTime? _selectedDate;
  File? _imageFile;
  bool _isLoading = false;

  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 50);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseStorage.instance
        .ref('items/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _submitItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _nameController.text.isEmpty || _imageFile == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(_imageFile!);

      await FirebaseFirestore.instance.collection('items').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'category': _category,
        'date': _selectedDate,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un objet')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lieu'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Catégorie :'),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _category,
                        items: const [
                          DropdownMenuItem(value: 'perdu', child: Text('Perdu')),
                          DropdownMenuItem(value: 'trouvé', child: Text('Trouvé')),
                        ],
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(_selectedDate == null
                          ? 'Aucune date choisie'
                          : 'Date : ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _selectDate,
                        child: const Text('Choisir la date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _imageFile != null
                      ? Image.file(_imageFile!, height: 150)
                      : const Text('Aucune image sélectionnée'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera),
                        label: const Text('Caméra'),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.image),
                        label: const Text('Galerie'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitItem,
                    icon: const Icon(Icons.send),
                    label: const Text('Soumettre'),
                  ),
                ],
              ),
            ),
    );
  }
}