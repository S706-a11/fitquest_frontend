class User {
  final int id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.xp,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name:
          json['displayName'] ?? json['name'] ?? '', // Backend uses displayName
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'xp': xp,
      'avatarUrl': avatarUrl,
    };
  }

  int get nextLevelXp => level * 100;
}
