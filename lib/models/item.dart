

class Item {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;
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
      'location': location,
      'date': date,
      'category': category,
      'tags': tags,
      'status': status,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      date: map['date'],
      category: map['category'],
      tags: List<String>.from(map['tags']),
      status: map['status'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }
}