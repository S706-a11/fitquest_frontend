class DailyGoal {
  DailyGoal({
    required this.id,
    required this.userId,
    required this.dateYmd,
    required this.targetMinutes,
    required this.targetReps,
    required this.targetDistanceM,
    required this.progressMinutes,
    required this.progressReps,
    required this.progressDistanceM,
    required this.status,
    this.completedAt,
    this.user,
  });

  final String id;
  final String userId;
  final DateTime? dateYmd;
  final int targetMinutes;
  final int targetReps;
  final int targetDistanceM;
  final int progressMinutes;
  final int progressReps;
  final int progressDistanceM;
  final String status;
  final DateTime? completedAt;
  final DailyGoalUser? user;

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      dateYmd: _parseDate(json['dateYmd']),
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 0,
      targetDistanceM: (json['targetDistanceM'] as num?)?.toInt() ?? 0,
      progressMinutes: (json['progressMinutes'] as num?)?.toInt() ?? 0,
      progressReps: (json['progressReps'] as num?)?.toInt() ?? 0,
      progressDistanceM: (json['progressDistanceM'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'Active',
      completedAt: _parseDateTime(json['completedAt']),
      user: json['user'] is Map<String, dynamic>
          ? DailyGoalUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String get statusLabel {
    final normalized = status.toLowerCase();
    if (normalized == '0' || normalized == 'active') return 'Active';
    if (normalized == '1' || normalized == 'completed') return 'Completed';
    if (normalized == '2' || normalized == 'failed') return 'Failed';
    return status;
  }

  double progressFraction(int progress, int target) {
    if (target <= 0) return 0;
    final fraction = progress / target;
    if (fraction.isNaN || fraction.isInfinite) return 0;
    return fraction.clamp(0, 1);
  }

  String get formattedDate {
    final date = dateYmd;
    if (date == null) return 'Unknown date';
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class DailyGoalUser {
  DailyGoalUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.streakCount,
  });

  final String id;
  final String? email;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int streakCount;

  factory DailyGoalUser.fromJson(Map<String, dynamic> json) {
    return DailyGoalUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String?,
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
    );
  }
}
