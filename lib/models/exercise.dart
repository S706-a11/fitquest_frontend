/// Model class for Exercise
class Exercise {
  final int id;
  final int userId;
  final String name;
  final String exerciseType;
  final String? description;
  final int? duration; // in seconds
  final double? distance; // in meters
  final int? reps;
  final double? weight; // in kg
  final int? calories;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Exercise({
    required this.id,
    required this.userId,
    required this.name,
    required this.exerciseType,
    this.description,
    this.duration,
    this.distance,
    this.reps,
    this.weight,
    this.calories,
    required this.createdAt,
    this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      exerciseType: json['exerciseType'] as String? ?? 'general',
      description: json['description'] as String?,
      duration: json['duration'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      calories: json['calories'] as int?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'exerciseType': exerciseType,
      'description': description,
      'duration': duration,
      'distance': distance,
      'reps': reps,
      'weight': weight,
      'calories': calories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get formatted duration (MM:SS)
  String getFormattedDuration() {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted distance (km)
  String getFormattedDistance() {
    if (distance == null) return '0.0 km';
    final km = distance! / 1000;
    return '${km.toStringAsFixed(2)} km';
  }

  /// Get formatted weight
  String getFormattedWeight() {
    if (weight == null) return '0 kg';
    return '${weight!.toStringAsFixed(1)} kg';
  }
}

/// Model class for Exercise Session
class ExerciseSession {
  final int id;
  final int userId;
  final String exerciseType;
  final int duration; // in seconds
  final double? distance; // in meters
  final int? calories;
  final List<Map<String, double>>? route; // GPS coordinates
  final Map<String, dynamic>? metrics;
  final int? questId;
  final DateTime completedAt;

  const ExerciseSession({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.duration,
    this.distance,
    this.calories,
    this.route,
    this.metrics,
    this.questId,
    required this.completedAt,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    List<Map<String, double>>? routeData;
    if (json['route'] != null) {
      routeData =
          (json['route'] as List)
              .map((e) => Map<String, double>.from(e as Map))
              .toList();
    }

    return ExerciseSession(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      exerciseType: json['exerciseType'] as String? ?? 'general',
      duration: json['duration'] as int? ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      calories: json['calories'] as int?,
      route: routeData,
      metrics: json['metrics'] as Map<String, dynamic>?,
      questId: json['questId'] as int?,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseType': exerciseType,
      'duration': duration,
      'distance': distance,
      'calories': calories,
      'route': route,
      'metrics': metrics,
      'questId': questId,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Get formatted duration (HH:MM:SS or MM:SS)
  String getFormattedDuration() {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted distance
  String getFormattedDistance() {
    if (distance == null) return '0.0 km';
    final km = distance! / 1000;
    return '${km.toStringAsFixed(2)} km';
  }

  /// Get pace (min/km)
  String getPace() {
    if (distance == null || distance == 0) return '--:--';
    final km = distance! / 1000;
    final paceSeconds = duration / km;
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Model class for Exercise Type
class ExerciseType {
  final int id;
  final String name;
  final String category;
  final String? description;
  final String? iconName;
  final bool tracksDistance;
  final bool tracksDuration;
  final bool tracksReps;
  final bool tracksWeight;

  const ExerciseType({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.iconName,
    this.tracksDistance = false,
    this.tracksDuration = false,
    this.tracksReps = false,
    this.tracksWeight = false,
  });

  factory ExerciseType.fromJson(Map<String, dynamic> json) {
    return ExerciseType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      tracksDistance: json['tracksDistance'] as bool? ?? false,
      tracksDuration: json['tracksDuration'] as bool? ?? false,
      tracksReps: json['tracksReps'] as bool? ?? false,
      tracksWeight: json['tracksWeight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'iconName': iconName,
      'tracksDistance': tracksDistance,
      'tracksDuration': tracksDuration,
      'tracksReps': tracksReps,
      'tracksWeight': tracksWeight,
    };
  }
}
