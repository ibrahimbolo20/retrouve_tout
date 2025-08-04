import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retrouve_tout/screens/main_screen.dart';
import 'package:retrouve_tout/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const LoginScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  

  if (email.isEmpty || password.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez remplir tous les champs')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    // Connexion réussie
    if (mounted) {
      widget.onFinish(); // Navigation ou changement d'état
    }

  } on FirebaseAuthException catch (e) {
    String error = 'Une erreur est survenue';
    if (e.code == 'user-not-found') {
      error = 'Utilisateur introuvable';
    } else if (e.code == 'wrong-password') {
      error = 'Mot de passe incorrect';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  if (mounted) {
    setState(() => _isLoading = false);
  }
}
final AuthService _authService = AuthService();

void _signInWithGoogle() async {
  final userCredential = await _authService.signInWithGoogle();
  if (userCredential != null) {
    // Connexion réussie
    // Navigue vers MainScreen ou autre
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainScreen()), // ou MainNavigation()
    );
  } else {
    // Connexion échouée
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Échec de la connexion avec Google')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
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
                  child: const Icon(Icons.search, color: Colors.white, size: 36),
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
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
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
                  ]
                ),
                const SizedBox(height: 24),
                _socialButton('Google', Colors.white, const Color(0xFF2C3E50), Icons.g_mobiledata,
                onTap: _signInWithGoogle,),
                
                const SizedBox(height: 16),
                _socialButton('Facebook', const Color(0xFF1877F2), Colors.white, Icons.facebook),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ? ', style: TextStyle(color: Color(0xFF7F8C8D))),
                    GestureDetector(
                      onTap: () {
                        // TODO: Naviguer vers l'écran d'inscription
                      },
                      child: const Text('S\'inscrire',
                          style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onFinish,
                  child: const Text('Ignorer pour le moment', style: TextStyle(color: Color(0xFF7F8C8D))),
                ),
              ],
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

  Widget _socialButton(String text, Color bgColor, Color textColor, IconData icon,{
  VoidCallback? onTap,
}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
           
          // TODO: Ajouter login Google/Facebook
      
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
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
}
