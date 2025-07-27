import 'package:flutter/material.dart';

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

                // Icône loupe
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

                // Titre
                const Text(
                  'Bon retour !',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                ),
                const SizedBox(height: 32),

                // Champ email
                _buildInputField(
                  controller: _emailController,
                  hintText: 'Adresse email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
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

                // Bouton Se connecter
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        widget.onFinish();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez remplir tous les champs')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Séparateur
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

                // Boutons Google & Facebook
                _socialButton('Google', Colors.white, const Color(0xFF2C3E50), Icons.g_mobiledata),
                const SizedBox(height: 16),
                _socialButton('Facebook', const Color(0xFF1877F2), Colors.white, Icons.facebook),

                const SizedBox(height: 24),

                // S'inscrire
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ? ', style: TextStyle(color: Color(0xFF7F8C8D))),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('S\'inscrire', style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ignorer
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

  Widget _socialButton(String text, Color bgColor, Color textColor, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
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
