/// Model class for Exercise
class Exercise {
  final String id; // UUID
  final String userId; // UUID
  final int exerciseTypeId;
  final String exerciseTypeName;
  final int? sets;
  final int? repsPerSet;
  final double? weightKg;
  final String? note;
  final DateTime startAt;
  final DateTime? endAt;
  final int? questId;
  final int? totalReps; // Auto-calculated by backend
  final double? totalWeight; // Auto-calculated by backend
  final int? duration; // Auto-calculated by backend (seconds)

  const Exercise({
    required this.id,
    required this.userId,
    required this.exerciseTypeId,
    required this.exerciseTypeName,
    this.sets,
    this.repsPerSet,
    this.weightKg,
    this.note,
    required this.startAt,
    this.endAt,
    this.questId,
    this.totalReps,
    this.totalWeight,
    this.duration,
  });

  bool get isCompleted => endAt != null;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      exerciseTypeId: json['exerciseTypeId'] as int? ?? 0,
      exerciseTypeName: json['exerciseTypeName'] as String? ?? 'Unknown',
      sets: json['sets'] as int?,
      repsPerSet: json['repsPerSet'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      note: json['note'] as String?,
      startAt:
          json['startAt'] != null
              ? DateTime.parse(json['startAt'] as String)
              : DateTime.now(),
      endAt:
          json['endAt'] != null
              ? DateTime.parse(json['endAt'] as String)
              : null,
      questId: json['questId'] as int?,
      totalReps: json['totalReps'] as int?,
      totalWeight: (json['totalWeight'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseTypeId': exerciseTypeId,
      'exerciseTypeName': exerciseTypeName,
      'sets': sets,
      'repsPerSet': repsPerSet,
      'weightKg': weightKg,
      'note': note,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'questId': questId,
      'totalReps': totalReps,
      'totalWeight': totalWeight,
      'duration': duration,
    };
  }

  /// Get formatted duration (MM:SS)
  String getFormattedDuration() {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted weight
  String getFormattedWeight() {
    if (weightKg == null) return '0 kg';
    return '${weightKg!.toStringAsFixed(1)} kg';
  }

  /// Get formatted total weight
  String getFormattedTotalWeight() {
    if (totalWeight == null) return '0 kg';
    return '${totalWeight!.toStringAsFixed(1)} kg';
  }

  /// Get completion summary
  String getCompletionSummary() {
    if (!isCompleted) {
      return 'Planned: ${sets ?? 0} sets × ${repsPerSet ?? 0} reps @ ${weightKg ?? 0} kg';
    }
    return 'Completed: ${totalReps ?? 0} total reps, ${getFormattedTotalWeight()}';
  }
}

/// Model class for Exercise Session
class ExerciseSession {
  final int id;
  final String userId;
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
      userId: json['userId'] as String? ?? '',
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
