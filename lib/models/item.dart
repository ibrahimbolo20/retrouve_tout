import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final GeoPoint location;    // Coordonnées GPS Firestore
  final DateTime date;        // Date au format DateTime
  final String category;
  final List<String> tags;
  final String status;
  final String? imageUrl;
  final String userId;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.tags,
    required this.status,
    this.imageUrl,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,                    // GeoPoint direct
      'date': date.toIso8601String(),         // Date convertie en String ISO8601
      'category': category,
      'tags': tags,
      'status': status,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] is GeoPoint
          ? map['location']
          : GeoPoint(0, 0),  // fallback si absent ou mauvais type
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),  // fallback à la date actuelle
      category: map['category'] ?? '',
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : <String>[],
      status: map['status'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      userId: map['userId'] ?? '',
    );
  }
}
