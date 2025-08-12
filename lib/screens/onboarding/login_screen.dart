import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retrouve_tout/screens/main_screen.dart';
import 'package:retrouve_tout/services/auth_service.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const LoginScreen({super.key, required this.onFinish});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    print('Tentative de connexion avec email: ${_emailController.text.trim()}');
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('Connexion réussie avec email');
      widget.onFinish();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = e.message ?? 'Erreur de connexion';
      }
      print('Erreur Firebase: ${e.code} - $message');
      _showError(message);
    } catch (e) {
      print('Erreur inattendue lors de la connexion email: $e');
      _showError('Erreur inattendue: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    print('Tentative de connexion avec Google');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Connexion Google annulée par l\'utilisateur');
        _showError('Connexion Google annulée');
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      print('Connexion Google réussie: ${googleUser.email}');
      widget.onFinish();
    } catch (e) {
      print('Erreur lors de la connexion Google: $e');
      _showError('Échec de la connexion Google: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);
    print('Tentative de connexion avec Facebook');
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);
        await _auth.signInWithCredential(facebookAuthCredential);
        print('Connexion Facebook réussie');
        widget.onFinish();
      } else {
        print('Connexion Facebook échouée: ${result.status}, ${result.message}');
        _showError('Connexion Facebook annulée ou échouée: ${result.message}');
      }
    } catch (e) {
      print('Erreur lors de la connexion Facebook: $e');
      _showError('Échec de la connexion Facebook: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (_validateEmail(email) != null) {
      _showError('Veuillez entrer un email valide');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Email de réinitialisation envoyé à $email');
      _showError('Email de réinitialisation envoyé');
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
      _showError('Erreur lors de la réinitialisation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _socialButton(String text, Color bgColor, Color textColor, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, color: textColor),
        label: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7F00),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(IconlyLight.search, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 32),
                        const Text('Bon retour !',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                        const SizedBox(height: 8),
                        const Text('Connectez-vous pour continuer',
                            style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D))),
                        const SizedBox(height: 32),
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'Adresse email',
                          icon: IconlyLight.message,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: 'Mot de passe',
                          icon: IconlyLight.lock,
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: const Text('Mot de passe oublié ?',
                                style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7F00),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Se connecter',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Ou continuer avec', style: TextStyle(color: Color(0xFF7F8C8D))),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _socialButton('Google', Colors.white, const Color(0xFF2C3E50), IconlyLight.login, _signInWithGoogle),
                        const SizedBox(height: 16),
                        _socialButton('Facebook', const Color(0xFF1877F2), Colors.white, IconlyLight.login, _signInWithFacebook),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Pas encore de compte? ',
                                style: TextStyle(color: Color(0xFF7F8C8D))),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterScreen(onFinish: widget.onFinish)),
                                );
                              },
                              child: const Text('S\'inscrire',
                                  style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: widget.onFinish,
                          child: const Text('Ignorer pour le moment',
                              style: TextStyle(color: Color(0xFF7F8C8D))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}