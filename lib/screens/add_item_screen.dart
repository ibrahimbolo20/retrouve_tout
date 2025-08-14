import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'onboarding/login_screen.dart';
import 'home_screen.dart';
import 'dart:typed_data';


class AddItemScreen extends StatefulWidget {
  final String? type; // 'perdu' ou 'trouvé'
  const AddItemScreen({super.key, this.type});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'Électronique'; // Catégorie par défaut
  String _status = 'perdu'; // Statut par défaut
  DateTime? _selectedDate;
  File? _imageFile;
  Uint8List? _webImageBytes;
  bool _isLoading = false;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialiser le statut selon widget.type
    if (widget.type != null) {
      _status = widget.type!;
    }
    // Vérifier si l'utilisateur est connecté
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onFinish: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour ajouter un objet')),
        );
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

  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    final info = await DeviceInfoPlugin().androidInfo;
   return info.version.sdkInt;

  }

  Future<void> _pickImage(ImageSource source) async {
    print('Début de la sélection d\'image : source=$source, plateforme=${kIsWeb ? "web" : "mobile"}');
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

    print('Statut de la permission (${source == ImageSource.camera ? "caméra" : "galerie"}) : $status');

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission refusée pour la ${source == ImageSource.camera ? "caméra" : "galerie"}'),
          action: SnackBarAction(
            label: 'Paramètres',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    try {
      final picked = await picker.pickImage(source: source, imageQuality: 50, maxWidth: 800, maxHeight: 800);
      if (picked == null) {
        print('Aucune image sélectionnée');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune image sélectionnée')),
        );
        return;
      }
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        print('Image web sélectionnée : ${picked.name}, taille=${bytes.length} bytes');
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null;
        });
      } else {
        print('Image mobile sélectionnée : ${picked.path}, taille=${await picked.length()} bytes');
        setState(() {
          _imageFile = File(picked.path);
          _webImageBytes = null;
        });
      }
    } catch (e, stackTrace) {
      print('Erreur lors de la sélection d\'image : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection d\'image : $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Erreur : Aucun utilisateur connecté pour le téléversement');
      return null;
    }
    if (_imageFile == null && _webImageBytes == null) {
      print('Erreur : Aucune image valide à téléverser');
      return null;
    }

    print('Début du téléversement : imageFile=${_imageFile?.path}, webImageBytes=${_webImageBytes?.length}');
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('items/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (kIsWeb) {
        await storageRef.putData(_webImageBytes!);
      } else {
        if (_imageFile != null && await _imageFile!.exists()) {
          await storageRef.putFile(_imageFile!);
        } else {
          print('Erreur : Le fichier image n\'existe pas');
          return null;
        }
      }
      final url = await storageRef.getDownloadURL();
      print('Image téléversée avec succès : $url');
      return url;
    } catch (e, stackTrace) {
      print('Erreur lors du téléversement : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléversement : $e')),
      );
      return null;
    }
  }

  Future<void> _submitItem() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    print('Début de la soumission : user=${user?.uid}, name=$name, category=$_category, status=$_status, date=$_selectedDate');

    String missingFields = '';
    if (user == null) missingFields += 'Utilisateur non connecté, ';
    if (name.isEmpty) missingFields += 'Nom, ';
    if (description.isEmpty) missingFields += 'Description, ';
    if (location.isEmpty) missingFields += 'Lieu, ';
    if (_imageFile == null && _webImageBytes == null) missingFields += 'Image, ';
    if (_selectedDate == null) missingFields += 'Date, ';
    if (missingFields.isNotEmpty) {
      print('Champs manquants : $missingFields');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir : ${missingFields.substring(0, missingFields.length - 2)}')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        print('Échec du téléversement de l\'image');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Échec du téléversement de l\'image')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('items').add({
        'name': name,
        'description': description,
        'location': location,
        'category': _category,
        'status': _status,
        'date': Timestamp.fromDate(_selectedDate!),
        'imageUrl': imageUrl,
        'userId': user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'tags': [],
      });

      print('Objet ajouté avec succès : name=$name, category=$_category, status=$_status, imageUrl=$imageUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objet ajouté avec succès')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e, stackTrace) {
      print('Erreur lors de l\'ajout de l\'objet : $e\n$stackTrace');
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      print('Date sélectionnée : $picked');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Ajouter un objet ${widget.type ?? 'perdu'}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom de l\'objet',
                        prefixIcon: const Icon(IconlyLight.bag),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Veuillez entrer le nom' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(IconlyLight.document),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Veuillez entrer une description' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Lieu',
                        prefixIcon: const Icon(IconlyLight.location),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Veuillez entrer le lieu' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: const Icon(IconlyLight.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Électronique', child: Text('Électronique')),
                        DropdownMenuItem(value: 'Vêtements', child: Text('Vêtements')),
                        DropdownMenuItem(value: 'Autres', child: Text('Autres')),
                      ],
                      onChanged: (val) => setState(() => _category = val!),
                      validator: (value) => value == null ? 'Veuillez sélectionner une catégorie' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedDate == null
                          ? 'Sélectionner la date'
                          : 'Date: ${_selectedDate!.toString().split(' ')[0]}'),
                      trailing: const Icon(IconlyLight.calendar),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(IconlyLight.camera),
                          label: const Text('Caméra'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(IconlyLight.image),
                          label: const Text('Galerie'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_imageFile != null || _webImageBytes != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: kIsWeb
                            ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                            : Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Soumettre',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}