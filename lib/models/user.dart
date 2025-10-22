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
    print('User.fromJson: Parsing user data: $json');

    try {
      // Handle ID as either String or int
      final id =
          json['id'] is int ? json['id'].toString() : json['id'] as String;

      return User(
        id: id,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? 'User',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        level: json['level'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        streakCount: json['streakCount'] as int? ?? 0,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0.0,
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now(),
      );
    } catch (e) {
      print('User.fromJson: Error parsing user: $e');
      rethrow;
    }
  }
}
