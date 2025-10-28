class User {
  final String id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final String? avatarUrl;
  final double? weightKg;
  final double? heightCm;
  final int streakCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.xp,
    this.avatarUrl,
    this.weightKg,
    this.heightCm,
    this.streakCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name:
          json['displayName'] ?? json['name'] ?? '', // Backend uses displayName
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
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
      'weightKg': weightKg,
      'heightCm': heightCm,
      'streakCount': streakCount,
    };
  }

  int get nextLevelXp => level * 100;

  String get displayName => name;
}
