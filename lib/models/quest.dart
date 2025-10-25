import 'dart:convert';

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
  final int? exercisesCount; // Total exercises linked to quest
  final int? completedExercisesCount; // Exercises that are completed
  // Optional target metrics for computing progress by totals
  final Map<String, dynamic>? targetMetrics;
  final int? targetReps;
  final double? targetWeight;
  final int? targetDuration; // seconds
  // Optional filters to determine which exercises count toward progress
  final List<int>? targetExerciseTypeIds;
  final List<String>? includeNameContains;

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
    this.exercisesCount,
    this.completedExercisesCount,
    this.targetMetrics,
    this.targetReps,
    this.targetWeight,
    this.targetDuration,
    this.targetExerciseTypeIds,
    this.includeNameContains,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    print('Quest.fromJson: Parsing quest data: $json');

    try {
      // Handle ID as either int or String
      final id =
          json['id'] is String
              ? int.parse(json['id'])
              : (json['id'] as int? ?? 0);

      // Handle priority as either int or String
      // Backend sends: 0=Low, 1=Medium, 2=High, 3=Critical
      String priorityString;
      if (json['priority'] is int) {
        switch (json['priority'] as int) {
          case 0:
            priorityString = 'Low';
            break;
          case 1:
            priorityString = 'Medium';
            break;
          case 2:
            priorityString = 'High';
            break;
          case 3:
            priorityString = 'Critical';
            break;
          default:
            priorityString = 'Medium';
        }
      } else {
        priorityString = json['priority'] as String? ?? 'Medium';
      }

      // Parse optional target metrics if present (support multiple casings/keys)
      Map<String, dynamic>? metrics;
      final rawMetrics = json['targetMetrics'] ?? json['TargetMetrics'];
      if (rawMetrics is Map<String, dynamic>) {
        metrics = rawMetrics;
      } else if (rawMetrics is String) {
        try {
          metrics = jsonDecode(rawMetrics) as Map<String, dynamic>;
        } catch (_) {
          metrics = null;
        }
      }

      // Helper to extract numeric target values from metrics or direct fields
      int? _asInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) {
          final p = int.tryParse(v);
          return p;
        }
        return null;
      }

      double? _asDouble(dynamic v) {
        if (v == null) return null;
        if (v is double) return v;
        if (v is int) return v.toDouble();
        if (v is String) return double.tryParse(v);
        return null;
      }

      // Extract duration seconds supporting multiple key formats and minutes conversion
      int? _durationSecondsFrom(
        Map<String, dynamic> j,
        Map<String, dynamic>? m,
      ) {
        // Prefer DTO fields (new keys first)
        final direct = _asInt(
          j['targetDurationSec'] ??
              j['TargetDurationSec'] ??
              j['targetDuration'] ??
              j['TargetDuration'],
        );
        if (direct != null) return direct;

        // From metrics map
        final mSec = _asInt(
          m?['targetDurationSec'] ??
              m?['totalDurationSec'] ??
              m?['totalDurationSeconds'] ??
              m?['duration'],
        );
        if (mSec != null) return mSec;

        final mMin = _asDouble(m?['durationMinutes']);
        if (mMin != null) return (mMin * 60).round();
        return null;
      }

      final targetReps = _asInt(
        json['targetReps'] ??
            json['TargetReps'] ??
            metrics?['targetReps'] ??
            metrics?['reps'] ??
            metrics?['totalReps'],
      );
      final targetWeight = _asDouble(
        json['targetWeight'] ??
            json['TargetWeight'] ??
            metrics?['targetWeight'] ??
            metrics?['weight'] ??
            metrics?['totalWeight'],
      );
      final targetDuration = _durationSecondsFrom(json, metrics);

      // Parse optional filters
      List<int>? _asIntList(dynamic v) {
        if (v == null) return null;
        final List<int> out = [];
        if (v is List) {
          for (final e in v) {
            final val = _asInt(e);
            if (val != null) out.add(val);
          }
        } else if (v is String) {
          // support comma-separated
          for (final part in v.split(',')) {
            final val = _asInt(part.trim());
            if (val != null) out.add(val);
          }
        }
        return out.isEmpty ? null : out;
      }

      List<String>? _asStringList(dynamic v) {
        if (v == null) return null;
        final List<String> out = [];
        if (v is List) {
          for (final e in v) {
            if (e == null) continue;
            out.add(e.toString());
          }
        } else if (v is String) {
          // comma-separated
          for (final part in v.split(',')) {
            final s = part.trim();
            if (s.isNotEmpty) out.add(s);
          }
        }
        return out.isEmpty ? null : out;
      }

      final targetExerciseTypeIds = _asIntList(
        json['targetExerciseTypeIds'] ??
            json['TargetExerciseTypeIds'] ??
            metrics?['exerciseTypeIds'] ??
            metrics?['includeExerciseTypeIds'],
      );
      final includeNameContains = _asStringList(
        json['includeNameContains'] ??
            json['IncludeNameContains'] ??
            metrics?['includeNameContains'] ??
            metrics?['nameContains'],
      );

      return Quest(
        id: id,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        priority: priorityString,
        xpReward: json['xpReward'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        dueDate: json['dueDate'] as String?,
        duration: json['duration'] as int?,
        totalReps: json['totalReps'] as int?,
        totalWeight: (json['totalWeight'] as num?)?.toDouble(),
        exercisesCount: json['exercisesCount'] as int?,
        completedExercisesCount: json['completedExercisesCount'] as int?,
        targetMetrics: metrics,
        targetReps: targetReps,
        targetWeight: targetWeight,
        targetDuration: targetDuration,
        targetExerciseTypeIds: targetExerciseTypeIds,
        includeNameContains: includeNameContains,
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
      'targetMetrics': targetMetrics,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'targetDuration': targetDuration,
      'targetExerciseTypeIds': targetExerciseTypeIds,
      'includeNameContains': includeNameContains,
    };
  }
}
