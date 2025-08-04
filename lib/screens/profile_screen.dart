import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Activer la persistance hors ligne pour Firestore
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool hasUser = snapshot.hasData;
        final User? user = snapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(74),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: true,
              title: Column(
                children: const [
                  SizedBox(height: 20),
                  Text(
                    "Profil",
                    style: TextStyle(
                      color: Color(0xFF1A202C),
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Gérez votre compte",
                    style: TextStyle(
                      color: Color(0xFF8C939E),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFFBFC6D1)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  tooltip: "Paramètres",
                ),
                const SizedBox(width: 16),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: Color(0xFFEAEAEA)),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 36),
                if (hasUser && user != null)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (userSnapshot.hasError) {
                        return const Center(child: Text('Erreur de chargement du profil'));
                      }

                      final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('items')
                            .where('userId', isEqualTo: user.uid)
                            .snapshots(),
                        builder: (context, itemsSnapshot) {
                          if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (itemsSnapshot.hasError) {
                            return const Center(child: Text('Erreur de chargement des statistiques'));
                          }

                          final items = itemsSnapshot.data?.docs ?? [];
                          final reported = items.length.toString();
                          final found = items.where((doc) => doc['status'] == 'trouvé').length.toString();

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('items')
                                .where('foundBy', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, helpedSnapshot) {
                              if (helpedSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (helpedSnapshot.hasError) {
                                return const Center(child: Text('Erreur de chargement des aides'));
                              }

                              final helped = helpedSnapshot.data?.docs.length.toString() ?? '0';

                              return _buildUserCard(
                                name: userData?['name'] ?? user.displayName ?? 'Utilisateur',
                                email: user.email ?? 'Aucun email',
                                joinDate: userData?['joinDate']?.toDate().toString().split(' ')[0] ?? 'Inconnu',
                                photoUrl: userData?['photoUrl'] ?? user.photoURL,
                                reported: reported,
                                found: found,
                                helped: helped,
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.person_outline, size: 64, color: Color(0xFFBFC6D1)),
                        const SizedBox(height: 16),
                        const Text(
                          "Aucun utilisateur inscrit",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF8C939E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Inscrivez-vous pour accéder à votre profil.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBFC6D1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/auth');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Se connecter / S\'inscrire',
                            style: TextStyle(color: Colors.white),
                            semanticsLabel: 'Se connecter ou s\'inscrire',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 22),
                _buildProfileItem(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  subtitle: "Voir vos notifications",
                  onTap: () {
                    if (hasUser) {
                      Navigator.pushNamed(context, '/notifications');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez vous connecter pour voir vos notifications')),
                      );
                    }
                  },
                ),
                _buildProfileItem(
                  icon: Icons.person_outline,
                  title: "Informations",
                  subtitle: "Modifiez votre profil",
                  onTap: () {
                    if (hasUser) {
                      Navigator.pushNamed(context, '/edit_profile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez vous connecter pour modifier votre profil')),
                      );
                    }
                  },
                ),
                _buildProfileItem(
                  icon: Icons.settings_outlined,
                  title: "Paramètres",
                  subtitle: "Notifications et préférences",
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _buildProfileItem(
                  icon: Icons.help_outline,
                  title: "Aide et soutien",
                  subtitle: "FAQ et contact",
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                if (hasUser)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      tileColor: Colors.white,
                      leading: const Icon(Icons.logout, color: Color(0xFFFF4D4F)),
                      title: const Text(
                        "Se déconnecter",
                        style: TextStyle(
                          color: Color(0xFFFF4D4F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Déconnexion réussie')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
                          );
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  // Carte utilisateur avec données dynamiques
  static Widget _buildUserCard({
    required String name,
    required String email,
    required String joinDate,
    String? photoUrl,
    required String reported,
    required String found,
    required String helped,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar dynamique
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE5E7EB),
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        placeholder: (context, url) => const Icon(Icons.person, color: Color(0xFFD1D5DB), size: 36),
                        errorWidget: (context, url, error) => const Icon(Icons.person, color: Color(0xFFD1D5DB), size: 36),
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: Color(0xFFD1D5DB), size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F1FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified, color: Color(0xFF2AA6B0), size: 15),
                              SizedBox(width: 2),
                              Text(
                                "Vérifié",
                                style: TextStyle(
                                  color: Color(0xFF2AA6B0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF8C939E),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Membre depuis $joinDate",
                      style: const TextStyle(
                        color: Color(0xFFB3B8C2),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(reported, "Signalés", color: const Color(0xFF23262F)),
              Container(width: 1, height: 24, color: const Color(0xFFE4E7ED)),
              _buildStat(found, "Retrouvés", color: const Color(0xFF10B981)),
              Container(width: 1, height: 24, color: const Color(0xFFE4E7ED)),
              _buildStat(helped, "Aidé·es", color: const Color(0xFF2AA6B0)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStat(String value, String label, {required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: color,
          ),
          semanticsLabel: '$value $label',
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8C939E),
          ),
        ),
      ],
    );
  }

  static Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.white,
        leading: Icon(icon, color: const Color(0xFFBFC6D1), semanticLabel: title),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF23262F)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF8C939E)),
        ),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFC9CDD2), size: 16),
      ),
    );
  }
}