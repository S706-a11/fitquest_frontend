class User {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final int level;
  final int xp;
  final int streakCount;
  final double weightKg;
  final double heightCm;
  final DateTime createdAt;
  //dont know yet about exercises, dailyGoals, monthlyGoals, quests

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.streakCount,
    required this.weightKg,
    required this.heightCm,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String tempId,
        'email': String email,
        'displayName': String displayName,
        'avatarUrl': String avatarUrl,
        'level': int level,
        'xp': int xp,
        'streakCount': int streakCount,
        'weightKg': double weightKg,
        'heightCm': double heightCm,
        'createdAt': String createdAt,
      } =>
        User(
          id: tempId,
          email: email,
          displayName: displayName,
          avatarUrl: avatarUrl,
          level: level,
          xp: xp,
          streakCount: streakCount,
          weightKg: weightKg,
          heightCm: heightCm,
          createdAt: DateTime.parse(createdAt),
        ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}
