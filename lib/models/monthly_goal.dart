class MonthlyGoal {
  MonthlyGoal({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
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
  final int year;
  final int month;
  final int targetMinutes;
  final int targetReps;
  final int targetDistanceM;
  final int progressMinutes;
  final int progressReps;
  final int progressDistanceM;
  final String status;
  final DateTime? completedAt;
  final MonthlyGoalUser? user;

  factory MonthlyGoal.fromJson(Map<String, dynamic> json) {
    return MonthlyGoal(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 0,
      targetDistanceM: (json['targetDistanceM'] as num?)?.toInt() ?? 0,
      progressMinutes: (json['progressMinutes'] as num?)?.toInt() ?? 0,
      progressReps: (json['progressReps'] as num?)?.toInt() ?? 0,
      progressDistanceM: (json['progressDistanceM'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'Active',
      completedAt: _parseDateTime(json['completedAt']),
      user: json['user'] is Map<String, dynamic>
          ? MonthlyGoalUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
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

  String get formattedMonth {
    const monthNames = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final index = (month - 1).clamp(0, monthNames.length - 1);
    return '${monthNames[index]} $year';
  }
}

class MonthlyGoalUser {
  MonthlyGoalUser({
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

  factory MonthlyGoalUser.fromJson(Map<String, dynamic> json) {
    return MonthlyGoalUser(
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
