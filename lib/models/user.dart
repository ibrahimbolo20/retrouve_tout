class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? joinDate;
  final int lostItems;
  final int foundItems;
  final int badges;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.joinDate,
    this.lostItems = 0,
    this.foundItems = 0,
    this.badges = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'joinDate': joinDate,
      'lostItems': lostItems,
      'foundItems': foundItems,
      'badges': badges,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      joinDate: map['joinDate'],
      lostItems: map['lostItems'] ?? 0,
      foundItems: map['foundItems'] ?? 0,
      badges: map['badges'] ?? 0,
    );
  }
}