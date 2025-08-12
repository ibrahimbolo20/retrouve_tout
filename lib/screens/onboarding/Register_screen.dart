import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:retrouve_tout/screens/main_screen.dart'; // Ajout pour utiliser les mêmes icônes que LoginScreen

class RegisterScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const RegisterScreen({super.key, required this.onFinish});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController=TextEditingController();
  final _phoneController=TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading= false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Réutilisation des méthodes de validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
    if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }
void _handleRegister() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
     final firebaseUser = userCredential.user;

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);
      final doc = await userDocRef.get();

      if (!mounted) return;

      if (!doc.exists) {
        await userDocRef.set({
          'uid': userCredential.user!.uid,
          'name': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'joinDate': Timestamp.now(),
          'phone': _phoneController.text.trim(),
          'photoUrl': firebaseUser?.photoURL ??
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
         
        });
      }

      if (!mounted) return;

      // ✅ Redirection automatique (remplace onFinish)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()), // ou ton écran principal
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Erreur inconnue';
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Un compte existe déjà pour cet email.';
      } else if (e.code == 'invalid-email') {
        message = 'L\'email est invalide.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: const Color(0xFFFF7F00),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildInputField(
                      controller: _usernameController,
                      hintText: 'Nom d\'utilisateur',
                      icon: IconlyLight.profile,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneController,
                      hintText: 'Numéro de téléphone',
                      icon: IconlyLight.call,
                   validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro';
                        }
                        final phoneRegExp = RegExp(r'^(\+223)?[0-9]{8}$');
                        if (!phoneRegExp.hasMatch(value)) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                       inputFormatters: [PhoneInputFormatter()]
                    ),
                    const SizedBox(height: 16),


                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Adresse email',
                    icon: IconlyLight.message, // Harmonisation avec LoginScreen
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Mot de passe',
                    icon: IconlyLight.lock, // Harmonisation avec LoginScreen
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? IconlyLight.show : IconlyLight.hide,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirmer mot de passe',
                    icon: IconlyLight.lock, // Harmonisation avec LoginScreen
                    obscureText: !_isConfirmPasswordVisible,
                    validator: _validateConfirmPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? IconlyLight.show : IconlyLight.hide,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F00)))
                    :ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: 
                      const Text(
                        'S\'inscrire',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Déjà un compte ? Se connecter',
                      style: TextStyle(color: Color(0xFFFF7F00)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator, // Ajout pour la validation
    List<TextInputFormatter>? inputFormatters, // ✅ AJOUT ICI

  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}