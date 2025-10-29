import 'package:flutter/material.dart';
import 'quest_tracker_page.dart';

/// Unified tracker page: delegates to QuestTrackerPage so distance and time
/// tracking share the same save flow, GPS, goals, and quest updates.
class DistanceTrackerPage extends StatelessWidget {
  /// Optional backend exercise type id (e.g., 91 Running, 92 Cycling, 93 Swimming)
  final int? exerciseTypeId;

  /// Display name for the exercise (used as title override)
  final String exerciseTypeName;

  const DistanceTrackerPage({
    Key? key,
    this.exerciseTypeId,
    this.exerciseTypeName = 'Distance Exercise',
  }) : super(key: key);

  String _mapToExerciseType(int? id, String name) {
    // Prefer id mapping if provided
    switch (id) {
      case 91: // Running
        return 'running';
      case 92: // Cycling
        return 'cycling';
      case 93: // Swimming
        return 'swimming';
    }

    // Fallback to name-based heuristics
    final n = name.toLowerCase();
    if (n.contains('run')) return 'running';
    if (n.contains('cycle') || n.contains('bike')) return 'cycling';
    if (n.contains('swim')) return 'swimming';
    if (n.contains('strength') || n.contains('weight')) return 'strength';
    return 'general';
  }

  @override
  Widget build(BuildContext context) {
    final exerciseType = _mapToExerciseType(exerciseTypeId, exerciseTypeName);

    return QuestTrackerPage(
      titleOverride: exerciseTypeName,
      exerciseType: exerciseType,
      // questId/xpOverride can be wired when needed by callers
    );
  }
}
