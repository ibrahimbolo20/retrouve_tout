import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditItemScreen extends StatefulWidget {
  final String itemId;

  const EditItemScreen({super.key, required this.itemId});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _tagsController;
  late TextEditingController _dateController;
  String _status = 'perdu';
  String _category = 'Autre';
  File? _imageFile;
  String? _imageUrl;

  final List<String> _categories = [
    'Téléphone',
    'Sac',
    'Clé',
    'Vêtement',
    'Autre'
  ];

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _tagsController = TextEditingController();
    _dateController = TextEditingController();
    _fetchItemData();
  }

  Future<void> _fetchItemData() async {
    final doc = await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _locationController.text = data['location'] ?? '';
        _tagsController.text = data['tags'] ?? '';
        _dateController.text = data['date'] ?? '';
        _status = data['status'] ?? 'perdu';
        _category = data['category'] ?? 'Autre';
        _imageUrl = data['imageUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      String? downloadUrl = _imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('items/${widget.itemId}.jpg');
        await storageRef.putFile(_imageFile!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.itemId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'tags': _tagsController.text,
        'date': _dateController.text,
        'status': _status,
        'category': _category,
        'imageUrl': downloadUrl,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objet mis à jour avec succès')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteItem() async {
    await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .delete();

    if (_imageUrl != null) {
      final storageRef = FirebaseStorage.instance
          .refFromURL(_imageUrl!);
      await storageRef.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Objet supprimé')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier l\'objet'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                    : _imageUrl != null
                        ? Image.network(_imageUrl!, height: 200, fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.camera_alt, size: 50),
                          ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Nom de l\'objet'),
                validator: (value) =>
                    value!.isEmpty ? 'Ce champ est requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Lieu'),
              ),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: 'Tags (virgule)'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date de perte'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Statut'),
                items: ['perdu', 'trouvé']
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: _categories
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateItem,
                child: Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
