import 'package:flutter/material.dart';
import '../main_screen.dart';
import '../../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Connexion',
          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.search, size: 40, color: Colors.white),
            ),
            SizedBox(height: 30),
            Text('Bon retour !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            Text('Connectez-vous pour continuer', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Adresse email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Mot de passe oublié ?', style: TextStyle(color: Colors.orange)),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez remplir tous les champs')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            SizedBox(height: 30),
            Text('Ou continuer avec', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            Column(
              children: [
                SocialLoginButton(
  icon: Icons.g_mobiledata,
  text: 'Google',
  color: Colors.white,
  textColor: Colors.grey[800]!,
  onPressed: () {
    // TODO: connecter avec Google
    print('Connexion Google');
  },
),
SizedBox(height: 15),
SocialLoginButton(
  icon: Icons.facebook,
  text: 'Facebook',
  color: Colors.blue[600]!,
  textColor: Colors.white,
  onPressed: () {
    // TODO: connecter avec Facebook
    print('Connexion Facebook');
  },
),

              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pas encore de compte ? ', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () {},
                  child: Text('S\'inscrire', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen())),
              child: Text('Ignorer pour le moment', style: TextStyle(color: Colors.grey[500])),
            ),
          ],
        ),
      ),
    );
  }
}