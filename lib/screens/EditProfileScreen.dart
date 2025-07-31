import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _showPasswordField = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Activer la persistance hors ligne pour Firestore
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    _loadUserData();
  }

  // Charger les données utilisateur depuis Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? user.displayName ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          _bioController.text = data['bio'] ?? '';
          _currentImageUrl = data['photoUrl'] ?? user.photoURL;
        });
      } else {
        setState(() {
          _nameController.text = user.displayName ?? '';
          _emailController.text = user.email ?? '';
          _bioController.text = '';
          _currentImageUrl = user.photoURL;
        });
      }
    }
  }

  // Sélectionner une image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // Supprimer l'image actuelle
  Future<void> _deleteImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(_currentImageUrl!);
        await ref.delete().catchError((e) {
          if (e.code != 'object-not-found') throw e;
        });
        setState(() {
          _imageFile = null;
          _currentImageUrl = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de l\'image : $e')),
        );
      }
    }
  }

  // Mettre à jour le profil
  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom ne peut pas être vide')),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un email valide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _currentImageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref('users/${user.uid}/profile.jpg');
        await ref.putFile(_imageFile!);
        photoUrl = await ref.getDownloadURL();
      }

      // Vérifier si l'email a changé
      if (_emailController.text.trim() != user.email) {
        if (_passwordController.text.isEmpty) {
          setState(() {
            _showPasswordField = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez entrer votre mot de passe pour modifier l\'email')),
          );
          return;
        }

        // Re-authentifier l'utilisateur
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un email de vérification a été envoyé. Veuillez vérifier votre nouvelle adresse email.')),
        );
      }

      // Mettre à jour Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim(),
        'photoUrl': photoUrl ?? '',
        'joinDate': Timestamp.now(),
      }, SetOptions(merge: true));

      // Mettre à jour le nom et la photo dans Firebase Auth
      await user.updateDisplayName(_nameController.text.trim());
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFBFC6D1), semanticLabel: 'Retour'),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFEAEAEA),
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: const Color(0xFFE4E7ED)),
                      ),
                      child: Center(
                        child: _imageFile != null
                            ? ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: _currentImageUrl!,
                                      placeholder: (context, url) => const Icon(Icons.person, size: 60, color: Color(0xFFBFC6D1)),
                                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Color(0xFFBFC6D1)),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person, size: 60, color: Color(0xFFBFC6D1)),
                      ),
                    ),
                  ),
                  if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _deleteImage,
                      child: const Text(
                        'Supprimer la photo',
                        style: TextStyle(color: Color(0xFFFF4D4F)),
                        semanticsLabel: 'Supprimer la photo de profil',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (_showPasswordField) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe actuel (requis pour changer l\'email)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Biographie',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        semanticsLabel: 'Enregistrer les modifications du profil',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}