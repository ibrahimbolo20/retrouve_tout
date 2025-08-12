import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    print('Initialisation de HomeScreen : selectedCategory=$selectedCategory, selectedTab=$selectedTab');
  }

  Future<void> _deleteItem(String itemId, String? imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour supprimer un objet')),
      );
      return;
    }

    try {
      print('Suppression de l\'objet : itemId=$itemId, imageUrl=$imageUrl');
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete().catchError((e) {
          if (e.code != 'object-not-found') throw e;
        });
      }
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
      print('Objet supprimé avec succès : itemId=$itemId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objet supprimé avec succès')),
      );
    } catch (e, stackTrace) {
      print('Erreur lors de la suppression : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String itemId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet objet ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF8C939E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(itemId, imageUrl);
            },
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFFFF4D4F))),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsFound(String itemId, String ownerId, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour marquer un objet comme retrouvé')),
      );
      return;
    }

    try {
      print('Marquage comme retrouvé : itemId=$itemId, ownerId=$ownerId, itemName=$itemName');
      await FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'status': 'trouvé',
        'timestamp': Timestamp.now(),
      });
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': ownerId,
        'message': "Votre objet '$itemName' a été marqué comme retrouvé !",
        'timestamp': Timestamp.now(),
        'read': false,
        'itemId': itemId,
      });
      print('Objet marqué comme retrouvé avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objet marqué comme retrouvé')),
      );
    } catch (e, stackTrace) {
      print('Erreur lors du marquage comme retrouvé : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _claimItem(String itemId, String ownerId, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour revendiquer un objet')),
      );
      return;
    }

    try {
      print('Revendication de l\'objet : itemId=$itemId, ownerId=$ownerId, itemName=$itemName');
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': ownerId,
        'message': "Quelqu'un a revendiqué votre objet '$itemName' !",
        'timestamp': Timestamp.now(),
        'read': false,
        'itemId': itemId,
      });
      print('Revendication envoyée avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revendication envoyée au propriétaire')),
      );
    } catch (e, stackTrace) {
      print('Erreur lors de la revendication : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _callOwner(String ownerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour contacter le propriétaire')),
      );
      return;
    }

    try {
      print('Tentative d\'appel du propriétaire : ownerId=$ownerId');
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
      final phone = userDoc.data()?['phone'] as String?;
      if (phone != null && phone.isNotEmpty) {
        final uri = Uri.parse('tel:$phone');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          print('Appel lancé : $phone');
        } else {
          print('Impossible de lancer l\'appel');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de lancer l\'appel')),
          );
        }
      } else {
        print('Numéro de téléphone non disponible');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro de téléphone non disponible')),
        );
      }
    } catch (e, stackTrace) {
      print('Erreur lors de l\'appel : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _emailOwner(String ownerId, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour envoyer un email')),
      );
      return;
    }

    try {
      print('Tentative d\'envoi d\'email au propriétaire : ownerId=$ownerId, itemName=$itemName');
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
      final email = userDoc.data()?['email'] as String?;
      if (email != null && email.isNotEmpty) {
        final Email emailObj = Email(
          body: 'Bonjour,\n\nJe pense avoir trouvé votre objet "$itemName". Pouvez-vous me confirmer les détails ?\n\nCordialement,\n${user.displayName ?? 'Utilisateur'}',
          subject: 'Objet trouvé : $itemName',
          recipients: [email],
          isHTML: false,
        );
        await FlutterEmailSender.send(emailObj);
        print('Email envoyé avec succès');
      } else {
        print('Adresse email non disponible');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse email non disponible')),
        );
      }
    } catch (e, stackTrace) {
      print('Erreur lors de l\'envoi d\'email : $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _shareItem(String itemName, String location, String status, String? imageUrl) async {
    print('Partage de l\'objet : itemName=$itemName, location=$location, status=$status');
    final text = 'Objet $status : $itemName à $location. Consultez RetrouveTout pour plus de détails !';
    await Share.share(text, subject: 'Objet $status sur RetrouveTout');
  }

  void _startChat(String ownerId, String itemName) {
    print('Démarrage du chat : ownerId=$ownerId, itemName=$itemName');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité de chat à implémenter pour $itemName avec l\'utilisateur $ownerId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(74),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            title: Column(
              children: const [
                SizedBox(height: 20),
                Text(
                  'RetrouveTout',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Retrouvez facilement vos objets perdus',
                  style: TextStyle(
                    color: Color(0xFF8C939E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            actions: [
              const Icon(IconlyLight.location, color: Color(0xFFBFC6D1)),
              const SizedBox(width: 4),
              const Text('Paris, FR', style: TextStyle(color: Color(0xFF8C939E))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(IconlyLight.setting, color: Color(0xFFBFC6D1)),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                tooltip: 'Paramètres',
              ),
              const SizedBox(width: 10),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xFFEAEAEA),
                height: 1,
              ),
            ),
          ),
        ),
        body: _buildHomeView(),
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          children: [
            _buildMotivationCard(),
            const SizedBox(height: 16),
            _buildCategories(),
            const SizedBox(height: 8),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildActiveCities(),
            const SizedBox(height: 16),
            _buildSuccessSection(),
            const SizedBox(height: 16),
            _buildMainCardList(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 342;
        print('Nombre d\'objets dans _buildMotivationCard : $count');
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20, bottom: 14),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF6ED), Color(0xFFE6FAF2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Icon(IconlyLight.heart, color: Color(0xFFFFA657), size: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ensemble, on retrouve tout !',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF23262F)),
              ),
              const SizedBox(height: 5),
              Text(
                'Rejoignez les $count personnes qui répondent aujourd\'hui',
                style: const TextStyle(color: Color(0xFF8C939E), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories() {
    List<Map<String, dynamic>> cats = [
      {'icon': IconlyLight.home, 'label': 'Tout'},
      {'icon': IconlyLight.activity, 'label': 'Électronique'},
      {'icon': IconlyLight.bag, 'label': 'Vêtements'},
      {'icon': IconlyLight.category, 'label': 'Autres'},
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(cats.length, (i) {
          final selected = selectedCategory == i;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cats[i]['icon'], size: 16, color: selected ? Colors.white : const Color(0xFF2AA6B0)),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        cats[i]['label'],
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF23262F),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                selected: selected,
                selectedColor: const Color(0xFFFF7F00),
                backgroundColor: const Color(0xFFF8F9FB),
                onSelected: (_) {
                  print('Catégorie sélectionnée : ${cats[i]['label']}');
                  setState(() => selectedCategory = i);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selected ? BorderSide.none : const BorderSide(color: Color(0xFFE4E7ED)),
                ),
                elevation: 0,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabs() {
    List<Map<String, dynamic>> tabs = [
      {'label': 'Tout', 'color': const Color(0xFFFF7F00), 'icon': IconlyLight.category},
      {'label': 'Perdus', 'color': const Color(0xFFFFA657), 'icon': IconlyLight.closeSquare},
      {'label': 'Trouvés', 'color': const Color(0xFF1FD07C), 'icon': IconlyLight.tickSquare},
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(tabs.length, (i) {
          final selected = selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tabs[i]['icon'], size: 16, color: selected ? Colors.white : tabs[i]['color']),
                  const SizedBox(width: 3),
                  Text(
                    tabs[i]['label'],
                    style: TextStyle(
                      color: selected ? Colors.white : tabs[i]['color'],
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: selected,
              selectedColor: tabs[i]['color'],
              backgroundColor: const Color(0xFFF8F9FB),
              onSelected: (_) {
                print('Onglet sélectionné : ${tabs[i]['label']}');
                setState(() => selectedTab = i);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: selected ? BorderSide.none : BorderSide(color: tabs[i]['color']),
              ),
              elevation: 0,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveCities() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> cities = [
          {'rank': '1', 'city': 'Paris', 'count': '0 objets'},
          {'rank': '2', 'city': 'Lyon', 'count': '0 objets'},
          {'rank': '3', 'city': 'Marseille', 'count': '0 objets'},
        ];

        if (snapshot.hasData) {
          final items = snapshot.data!.docs;
          final cityCounts = <String, int>{};
          for (var item in items) {
            final location = (item.data() as Map<String, dynamic>)['location'] as String? ?? 'Inconnu';
            cityCounts[location] = (cityCounts[location] ?? 0) + 1;
          }
          final sortedCities = cityCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          cities = sortedCities.asMap().entries.take(3).map((entry) {
            return {
              'rank': '${entry.key + 1}',
              'city': entry.value.key,
              'count': '${entry.value.value} objets',
            };
          }).toList();
          print('Villes actives : $cities');
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(IconlyLight.location, color: Color(0xFF2AA6B0)),
                  SizedBox(width: 7),
                  Text(
                    'Les villes les plus actives',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF23262F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...cities.map((c) => _buildCityItem(c['rank']!, c['city']!, c['count']!)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCityItem(String rank, String city, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFEBF5FF),
            child: Text(rank, style: const TextStyle(color: Color(0xFF2AA6B0), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(city, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(count, style: const TextStyle(color: Color(0xFF8C939E))),
        ],
      ),
    );
  }

  Widget _buildSuccessSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('status', isEqualTo: 'trouvé')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Erreur dans _buildSuccessSection : ${snapshot.error}');
          return const Center(child: Text('Erreur de chargement des succès'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('Aucun succès récent trouvé');
          return const Center(child: Text('Aucun succès récent'));
        }

        final items = snapshot.data!.docs;
        print('Succès récents : ${items.length} objets trouvés');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(IconlyLight.star, color: Color(0xFF2AA6B0)),
                  SizedBox(width: 7),
                  Text(
                    'Succès récents',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF23262F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...items.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildSuccessItem(
                  data['name'] ?? 'Sans titre',
                  data['location'] ?? 'Lieu inconnu',
                  (data['timestamp'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'Date inconnue',
                  IconlyLight.tickSquare,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessItem(String item, String location, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FAF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF2AA6B0), child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Icon(IconlyLight.location, size: 14, color: Color(0xFFBFC6D1)),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Color(0xFF8C939E), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Color(0xFF8C939E), fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1FD07C), borderRadius: BorderRadius.circular(4)),
                child: const Text('Retrouvé', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCardList() {
    const categoryMap = {
      0: null,
      1: 'Électronique',
      2: 'Vêtements',
      3: 'Autres',
    };

    const tabMap = {
      0: null,
      1: 'perdu',
      2: 'trouvé',
    };

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('items').orderBy('timestamp', descending: true);

    if (selectedCategory != 0 && categoryMap[selectedCategory] != null) {
      query = query.where('category', isEqualTo: categoryMap[selectedCategory]);
    }

    if (selectedTab != 0 && tabMap[selectedTab] != null) {
      query = query.where('status', isEqualTo: tabMap[selectedTab]);
    }

    return StreamBuilder<QuerySnapshot>(
      key: ValueKey('$selectedCategory-$selectedTab'),
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Erreur dans _buildMainCardList : ${snapshot.error}');
          return const Center(child: Text('Erreur de chargement des données'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('Aucun objet trouvé pour category=${categoryMap[selectedCategory]}, status=${tabMap[selectedTab]}');
          return const Center(child: Text('Aucun objet trouvé'));
        }

        final items = snapshot.data!.docs;
        print('Objets chargés : ${items.length}');

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            final itemId = items[index].id;
            print('Affichage de l\'objet : itemId=$itemId, name=${item['name']}, category=${item['category']}, status=${item['status']}');
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: item['status'] == 'perdu'
                  ? _buildLostItemCard(
                      itemId: itemId,
                      title: item['name'] ?? 'Sans titre',
                      location: item['location'] ?? 'Lieu inconnu',
                      time: (item['date'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'Date inconnue',
                      category: item['category'] ?? 'Autres',
                      description: item['description'] ?? '',
                      imageUrl: item['imageUrl'] ?? '',
                      tags: (item['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                      userId: item['userId'] ?? '',
                    )
                  : _buildFoundItemCard(
                      itemId: itemId,
                      title: item['name'] ?? 'Sans titre',
                      location: item['location'] ?? 'Lieu inconnu',
                      time: (item['date'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? 'Date inconnue',
                      category: item['category'] ?? 'Autres',
                      tags: (item['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                      imageUrl: item['imageUrl'] ?? '',
                      userId: item['userId'] ?? '',
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildLostItemCard({
    required String itemId,
    required String title,
    required String location,
    required String time,
    required String category,
    required String description,
    required String imageUrl,
    required List<String> tags,
    required String userId,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, top: 14, bottom: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7F00),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Perdu",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E7ED)),
            ),
            child: Center(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const Icon(IconlyLight.image, size: 50, color: Color(0xFFBFC6D1)),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.cover,
                    )
                  : const Icon(IconlyLight.image, size: 50, color: Color(0xFFBFC6D1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF2AA6B0),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(IconlyLight.timeCircle, color: Color(0xFFB3B8C2), size: 15),
                    const SizedBox(width: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFFB3B8C2),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF23262F),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(IconlyLight.location, size: 15, color: Color(0xFFBFC6D1)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Color(0xFF8C939E), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1FD07C),
                          minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          elevation: 0,
                        ),
                        onPressed: () => _markAsFound(itemId, userId, title),
                        child: const Text(
                          "J'ai trouvé",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          semanticsLabel: "Marquer comme retrouvé",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(IconlyLight.call, color: Color(0xFF2AA6B0)),
                      onPressed: () => _callOwner(userId),
                      tooltip: 'Appeler le propriétaire',
                    ),
                    IconButton(
                      icon: const Icon(IconlyLight.message, color: Color(0xFF2AA6B0)),
                      onPressed: () => _emailOwner(userId, title),
                      tooltip: 'Envoyer un email au propriétaire',
                    ),
                    if (userId == FirebaseAuth.instance.currentUser?.uid)
                      PopupMenuButton<String>(
                        icon: const Icon(IconlyLight.moreSquare, color: Color(0xFF2AA6B0), semanticLabel: 'Plus d\'options'),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmationDialog(itemId, imageUrl);
                          } else if (value == 'edit') {
                            Navigator.pushNamed(context, '/edit_item', arguments: itemId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(IconlyLight.edit, color: Color(0xFF2AA6B0)),
                                SizedBox(width: 8),
                                Text('Modifier', style: TextStyle(color: Color(0xFF2AA6B0))),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(IconlyLight.delete, color: Color(0xFFFF4D4F)),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Color(0xFFFF4D4F))),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _startChat(userId, title),
                        icon: const Icon(IconlyLight.chat, color: Color(0xFF2AA6B0), size: 20),
                        label: const Text("Chat", style: TextStyle(color: Color(0xFF2AA6B0))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4E7ED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareItem(title, location, 'perdu', imageUrl),
                        icon: const Icon(Icons.share, color: Color(0xFF2AA6B0), size: 20),
                        label: const Text("Partager", style: TextStyle(color: Color(0xFF2AA6B0))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4E7ED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundItemCard({
    required String itemId,
    required String title,
    required String location,
    required String time,
    required String category,
    required List<String> tags,
    required String imageUrl,
    required String userId,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, top: 14, bottom: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1FD07C),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Trouvé",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E7ED)),
            ),
            child: Center(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const Icon(IconlyLight.image, size: 50, color: Color(0xFFBFC6D1)),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.cover,
                    )
                  : const Icon(IconlyLight.image, size: 50, color: Color(0xFFBFC6D1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF2AA6B0),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(IconlyLight.timeCircle, color: Color(0xFFB3B8C2), size: 15),
                    const SizedBox(width: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFFB3B8C2),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$title trouvé à $location.",
                  style: const TextStyle(
                    color: Color(0xFF23262F),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(IconlyLight.location, size: 15, color: Color(0xFFBFC6D1)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Color(0xFF8C939E), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F00),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      elevation: 0,
                    ),
                    onPressed: () => _claimItem(itemId, userId, title),
                    child: const Text(
                      "C'est à moi",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      semanticsLabel: "Revendiquer l'objet",
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _startChat(userId, title),
                        icon: const Icon(IconlyLight.chat, color: Color(0xFF2AA6B0), size: 20),
                        label: const Text("Chat", style: TextStyle(color: Color(0xFF2AA6B0))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4E7ED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareItem(title, location, 'trouvé', imageUrl),
                        icon: const Icon(Icons.share, color: Color(0xFF2AA6B0), size: 20),
                        label: const Text("Partager", style: TextStyle(color: Color(0xFF2AA6B0))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4E7ED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ),
                    if (userId == FirebaseAuth.instance.currentUser?.uid)
                      PopupMenuButton<String>(
                        icon: const Icon(IconlyLight.moreSquare, color: Color(0xFF2AA6B0), semanticLabel: 'Plus d\'options'),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmationDialog(itemId, imageUrl);
                          } else if (value == 'edit') {
                            Navigator.pushNamed(context, '/edit_item', arguments: itemId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(IconlyLight.edit, color: Color(0xFF2AA6B0)),
                                SizedBox(width: 8),
                                Text('Modifier', style: TextStyle(color: Color(0xFF2AA6B0))),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(IconlyLight.delete, color: Color(0xFFFF4D4F)),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Color(0xFFFF4D4F))),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF23262F),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}