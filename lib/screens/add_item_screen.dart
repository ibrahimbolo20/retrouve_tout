import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'dart:io' show File, Platform;
import 'dart:typed_data';

class AddItemScreen extends StatefulWidget {
  final String? type; // Paramètre optionnel pour la catégorie initiale
  const AddItemScreen({Key? key, this.type}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'perdu'; // Pré-rempli avec le type si fourni
  DateTime? _selectedDate;
  File? _imageFile; // Pour Android/iOS
  Uint8List? _webImageBytes; // Pour le web
  bool _isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.type == 'trouvé') {
      _category = 'trouvé';
    }
  }

  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    return deviceInfo.version.sdkInt;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) {
      try {
        final picked = await picker.pickImage(source: source, imageQuality: 50);
        if (picked == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune image sélectionnée')),
          );
          return;
        }
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null; // Pas de File sur le web
          print('Image web sélectionnée : ${picked.name}, bytes : ${bytes.length}');
        });
      } catch (e) {
        print('Erreur lors de la sélection d\'image (web) : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection d\'image : $e')),
        );
      }
      return;
    }

    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      try {
        final picked = await picker.pickImage(source: source, imageQuality: 50);
        if (picked == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune image sélectionnée')),
          );
          return;
        }
        setState(() {
          _imageFile = File(picked.path);
          _webImageBytes = null; // Pas de bytes sur mobile
          print('Image sélectionnée : ${picked.path}');
        });
      } catch (e) {
        print('Erreur lors de la sélection d\'image : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection d\'image : $e')),
        );
      }
    } else {
      print('Permission refusée : ${source == ImageSource.camera ? "caméra" : "galerie"}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission refusée pour ${source == ImageSource.camera ? "la caméra" : "la galerie"}')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Erreur : Aucun utilisateur connecté');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun utilisateur connecté')),
      );
      return null;
    }

    final ref = FirebaseStorage.instance
        .ref('items/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      if (kIsWeb && _webImageBytes != null) {
        await ref.putData(_webImageBytes!);
      } else if (_imageFile != null && await _imageFile!.exists()) {
        await ref.putFile(_imageFile!);
      } else {
        print('Erreur : Aucune image valide à téléverser');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Aucune image valide à téléverser')),
        );
        return null;
      }
      final url = await ref.getDownloadURL();
      print('Image téléversée : $url');
      return url;
    } catch (e) {
      print('Erreur lors du téléversement : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléversement : $e')),
      );
      return null;
    }
  }

  Future<void> _submitItem() async {
    final user = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.trim();

    print('Validation des champs :');
    print('Utilisateur connecté : ${user != null}');
    print('Nom : "$name" (vide : ${name.isEmpty})');
    print('Image sélectionnée : ${_imageFile != null || _webImageBytes != null}');
    print('Date sélectionnée : ${_selectedDate != null}');

    if (user == null || name.isEmpty || (_imageFile == null && _webImageBytes == null) || _selectedDate == null) {
      String missingFields = '';
      if (user == null) missingFields += 'Utilisateur non connecté, ';
      if (name.isEmpty) missingFields += 'Nom, ';
      if (_imageFile == null && _webImageBytes == null) missingFields += 'Image, ';
      if (_selectedDate == null) missingFields += 'Date, ';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir : ${missingFields.substring(0, missingFields.length - 2)}')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('items').add({
        'name': name,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _category,
        'date': _selectedDate,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': _category,
      });

      print('Objet ajouté avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objet ajouté avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'objet : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        print('Date sélectionnée : $_selectedDate');
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
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
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Catégorie :', style: TextStyle(fontSize: 16)),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Aucune date choisie'
                            : 'Date : ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _selectDate,
                        child: const Text('Choisir la date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _imageFile != null
                      ? kIsWeb
                          ? _webImageBytes != null
                              ? Image.memory(_webImageBytes!, height: 150, fit: BoxFit.cover)
                              : const Text('Aucune image sélectionnée')
                          : Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
                      : const Text('Aucune image sélectionnée'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(IconlyLight.camera, color: Color(0xFF2AA6B0), size: 24),
                        label: const Text('Caméra', style: TextStyle(color: Color(0xFF2AA6B0))),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(IconlyLight.image, color: Color(0xFF2AA6B0), size: 24),
                        label: const Text('Galerie', style: TextStyle(color: Color(0xFF2AA6B0))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitItem,
                    icon: const Icon(IconlyLight.send, color: Colors.white, size: 24),
                    label: const Text('Soumettre', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}