class Quest {
  final int id;
  final String title;
  final String description;
  final String priority;
  final int xpReward;
  final bool isCompleted;
  final String? dueDate;
  final int? duration;
  final int? totalReps;
  final double? totalWeight;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.xpReward,
    required this.isCompleted,
    this.dueDate,
    this.duration,
    this.totalReps,
    this.totalWeight,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    print('Quest.fromJson: Parsing quest data: $json');

    try {
      // Handle ID as either int or String
      final id =
          json['id'] is String
              ? int.parse(json['id'])
              : (json['id'] as int? ?? 0);

      return Quest(
        id: id,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        priority: json['priority'] as String? ?? 'Medium',
        xpReward: json['xpReward'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        dueDate: json['dueDate'] as String?,
        duration: json['duration'] as int?,
        totalReps: json['totalReps'] as int?,
        totalWeight: (json['totalWeight'] as num?)?.toDouble(),
      );
    } catch (e) {
      print('Quest.fromJson: Error parsing quest: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'dueDate': dueDate,
      'duration': duration,
      'totalReps': totalReps,
      'totalWeight': totalWeight,
    };
  }
}
