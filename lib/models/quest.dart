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
    return Quest(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      xpReward: json['xpReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'],
      duration: json['duration'],
      totalReps: json['totalReps'],
      totalWeight: json['totalWeight']?.toDouble(),
    );
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
