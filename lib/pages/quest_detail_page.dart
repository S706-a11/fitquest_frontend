import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../services/exercise_service.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import 'link_exercise_to_quest_page.dart';

class QuestDetailPage extends StatefulWidget {
  final int questId;

  const QuestDetailPage({Key? key, required this.questId}) : super(key: key);

  @override
  State<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends State<QuestDetailPage> {
  Quest? _quest;
  List<dynamic> _exercises = [];
  bool _isLoading = true;

  // ---- Helpers: robust numeric parsing and totals extraction ----
  num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  int? _asInt(dynamic v) {
    final n = _asNum(v);
    return n?.toInt();
  }

  double? _asDouble(dynamic v) {
    final n = _asNum(v);
    return n?.toDouble();
  }

  dynamic _getAny(Map<String, dynamic> ex, List<String> keys) {
    for (final k in keys) {
      if (ex.containsKey(k) && ex[k] != null) return ex[k];
    }
    return null;
  }

  bool _includeExerciseForQuestFilters(Map<String, dynamic> ex) {
    // Must be completed to count toward progress/totals
    if (ex['endAt'] == null) return false;
    // Filter by type IDs if provided
    final typeFilter = _quest?.targetExerciseTypeIds;
    if (typeFilter != null && typeFilter.isNotEmpty) {
      final typeId = _asInt(_getAny(ex, const ['exerciseTypeId', 'typeId']));
      if (typeId == null || !typeFilter.contains(typeId)) return false;
    }
    // Filter by name/note substrings if provided
    final nameFilters = _quest?.includeNameContains;
    if (nameFilters != null && nameFilters.isNotEmpty) {
      final name =
          (_getAny(ex, const ['exerciseTypeName', 'name'])?.toString() ?? '')
              .toLowerCase();
      final note = (ex['note']?.toString() ?? '').toLowerCase();
      final match = nameFilters.any((s) {
        final t = s.toLowerCase();
        return name.contains(t) || note.contains(t);
      });
      if (!match) return false;
    }
    return true;
  }

  int? _getTotalReps(Map<String, dynamic> ex) {
    // Try multiple casings/aliases
    final raw = _getAny(ex, const [
      'totalReps',
      'TotalReps',
      'repsTotal',
      'total_rep',
      'total_rep_count',
    ]);
    int? reps = _asInt(raw);
    // Treat zero or null as missing and compute fallback when possible
    if (reps == null || reps <= 0) {
      final sets = _asInt(_getAny(ex, const ['sets', 'Sets']));
      final repsPerSet = _asInt(
        _getAny(ex, const ['repsPerSet', 'RepsPerSet', 'reps']),
      );
      if (sets != null && repsPerSet != null) {
        reps = sets * repsPerSet;
      }
    }
    return reps;
  }

  double? _getTotalWeight(Map<String, dynamic> ex) {
    final raw = _getAny(ex, const [
      'totalWeight',
      'TotalWeight',
      'total_weight',
    ]);
    double? w = _asDouble(raw);
    if (w == null || w <= 0) {
      final sets = _asInt(_getAny(ex, const ['sets', 'Sets']));
      final repsPerSet = _asInt(
        _getAny(ex, const ['repsPerSet', 'RepsPerSet', 'reps']),
      );
      final weightKg = _asDouble(
        _getAny(ex, const ['weightKg', 'WeightKg', 'weight']),
      );
      if (sets != null && repsPerSet != null && weightKg != null) {
        w = sets * repsPerSet * weightKg;
      }
    }
    return w;
  }

  int? _getDuration(Map<String, dynamic> ex) {
    final raw = _getAny(ex, const ['duration', 'Duration', 'totalDurationSec']);
    int? d = _asInt(raw);
    if (d == null || d < 0) {
      // Fallback: compute from timestamps if available
      final startAtStr = _getAny(ex, const ['startAt', 'StartAt'])?.toString();
      final endAtStr = _getAny(ex, const ['endAt', 'EndAt'])?.toString();
      if (startAtStr != null && endAtStr != null) {
        try {
          final start = DateTime.parse(startAtStr);
          final end = DateTime.parse(endAtStr);
          d = end.difference(start).inSeconds;
        } catch (_) {}
      }
    }
    return d;
  }

  int? _getSets(Map<String, dynamic> ex) {
    // Prefer explicit sets field
    final raw = _getAny(ex, const ['sets', 'Sets', 'totalSets', 'TotalSets']);
    int? sets = _asInt(raw);
    if ((sets == null || sets <= 0)) {
      // Try to derive from totalReps and repsPerSet if available
      final repsTotal = _getTotalReps(ex);
      final repsPerSet = _asInt(
        _getAny(ex, const ['repsPerSet', 'RepsPerSet', 'reps']),
      );
      if (repsTotal != null && repsPerSet != null && repsPerSet > 0) {
        final derived = repsTotal / repsPerSet;
        if (derived.isFinite) {
          sets = derived.round();
        }
      }
    }
    return sets;
  }

  String? _resolveExerciseTypeName(int typeId) {
    for (final raw in _exercises) {
      final ex = raw as Map<String, dynamic>;
      final id = _asInt(_getAny(ex, const ['exerciseTypeId', 'typeId']));
      if (id == typeId) {
        final name = _getAny(ex, const ['exerciseTypeName', 'name']);
        if (name != null) return name.toString();
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _groupByExerciseType() {
    final Map<int, Map<String, dynamic>> groups = {};
    for (final raw in _exercises) {
      final ex = raw as Map<String, dynamic>;
      final typeId = _asInt(_getAny(ex, const ['exerciseTypeId', 'typeId']));
      if (typeId == null) continue;
      final isCompleted = ex['endAt'] != null;
      final name = _getAny(ex, const ['exerciseTypeName', 'name'])?.toString();
      final sets = _getSets(ex) ?? 0;
      final reps = _getTotalReps(ex) ?? 0;
      final weight = _getTotalWeight(ex) ?? 0.0;
      final duration = _getDuration(ex) ?? 0;

      final g = groups.putIfAbsent(
        typeId,
        () => {
          'typeId': typeId,
          'name': name,
          'total': 0,
          'completed': 0,
          'sets': 0,
          'reps': 0,
          'weight': 0.0,
          'duration': 0,
        },
      );
      g['total'] = (g['total'] as int) + 1;
      if (isCompleted) g['completed'] = (g['completed'] as int) + 1;
      g['sets'] = (g['sets'] as int) + sets;
      g['reps'] = (g['reps'] as int) + reps;
      g['weight'] = (g['weight'] as double) + weight;
      g['duration'] = (g['duration'] as int) + duration;
      if (g['name'] == null && name != null) g['name'] = name;
    }
    final list = groups.values.toList();
    list.sort(
      (a, b) => (b['completed'] as int).compareTo(a['completed'] as int),
    );
    return list;
  }

  // Compute quest progress [0..1] using target metrics when available,
  // otherwise fall back to completed exercises ratio.
  double _computeProgressRatio() {
    if (_quest == null) return 0.0;

    final List<double> parts = [];

    bool _includeExercise(Map<String, dynamic> ex) =>
        _includeExerciseForQuestFilters(ex);

    // Resolve totals from quest or aggregate from exercises
    int? _aggTotalReps() {
      if (_quest!.totalReps != null) return _quest!.totalReps;
      int sum = 0;
      bool any = false;
      for (final raw in _exercises) {
        final ex = raw as Map<String, dynamic>;
        if (!_includeExercise(ex)) continue;
        final v = _getTotalReps(ex);
        if (v != null && v > 0) {
          sum += v;
          any = true;
        }
      }
      return any ? sum : null;
    }

    double? _aggTotalWeight() {
      if (_quest!.totalWeight != null) return _quest!.totalWeight;
      double sum = 0.0;
      bool any = false;
      for (final raw in _exercises) {
        final ex = raw as Map<String, dynamic>;
        if (!_includeExercise(ex)) continue;
        final w = _getTotalWeight(ex);
        if (w != null && w > 0) {
          sum += w;
          any = true;
        }
      }
      return any ? sum : null;
    }

    int? _aggDuration() {
      if (_quest!.duration != null) return _quest!.duration;
      int sum = 0;
      bool any = false;
      for (final raw in _exercises) {
        final ex = raw as Map<String, dynamic>;
        if (!_includeExercise(ex)) continue;
        final d = _getDuration(ex);
        if (d != null && d > 0) {
          sum += d;
          any = true;
        }
      }
      return any ? sum : null;
    }

    // By totals: reps
    final totalReps = _aggTotalReps();
    final targetReps = _quest!.targetReps;
    if (totalReps != null && targetReps != null && targetReps > 0) {
      parts.add((totalReps / targetReps).clamp(0.0, 1.0));
    }

    // By totals: weight
    final totalWeight = _aggTotalWeight();
    final targetWeight = _quest!.targetWeight;
    if (totalWeight != null && targetWeight != null && targetWeight > 0) {
      parts.add((totalWeight / targetWeight).clamp(0.0, 1.0));
    }

    // By totals: duration (seconds)
    final duration = _aggDuration();
    final targetDuration = _quest!.targetDuration;
    if (duration != null && targetDuration != null && targetDuration > 0) {
      parts.add((duration / targetDuration).clamp(0.0, 1.0));
    }

    // By totals: sets
    int? _aggTotalSets() {
      if (_quest!.totalSets != null) return _quest!.totalSets;
      int sum = 0;
      bool any = false;
      for (final raw in _exercises) {
        final ex = raw as Map<String, dynamic>;
        if (!_includeExercise(ex)) continue;
        final s = _getSets(ex);
        if (s != null && s > 0) {
          sum += s;
          any = true;
        }
      }
      return any ? sum : null;
    }

    final totalSets = _aggTotalSets();
    final targetSets = _quest!.targetSets;
    if (totalSets != null && targetSets != null && targetSets > 0) {
      parts.add((totalSets / targetSets).clamp(0.0, 1.0));
    }

    if (parts.isNotEmpty) {
      // Use the average of available metrics
      final avg = parts.reduce((a, b) => a + b) / parts.length;
      return avg.clamp(0.0, 1.0);
    }

    // Fallback: ratio of completed exercises
    final totalCount = _exercises.length;
    if (totalCount == 0) return 0.0;
    final completedCount = _exercises.where((ex) => ex['endAt'] != null).length;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestDetails();
  }

  Future<void> _loadQuestDetails() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final questData = await QuestService.getQuestById(
        userId: userId.toString(),
        questId: widget.questId,
      );
      final exercises = await QuestService.getQuestExercises(
        userId: userId.toString(),
        questId: widget.questId,
      );

      setState(() {
        _quest = Quest.fromJson(questData);
        _exercises = exercises;
        _isLoading = false;
      });

      // Auto-complete quest if all exercises are completed
      await _checkAndAutoCompleteQuest();
    } catch (e) {
      print('Error loading quest details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndAutoCompleteQuest() async {
    if (_quest == null || _quest!.isCompleted) return;

    // Compute progress (by targets if available, else by completed exercises)
    final ratio = _computeProgressRatio();
    final progressPercent = (ratio * 100).toInt();
    print('Auto-complete check: progress=$progressPercent%');

    if (ratio >= 1.0) {
      print('Progress reached 100%! Auto-completing quest...');

      final userProvider = context.read<UserProvider>();
      final userId = userProvider.user?.id;
      final beforeLevel = userProvider.user?.level ?? 0;
      final beforeXp = userProvider.user?.xp ?? 0;
      if (userId == null) return;

      try {
        await QuestService.toggleQuestStatus(
          userId: userId.toString(),
          questId: widget.questId,
          completed: true, // Explicitly mark as completed
        );

        // Reload to get updated quest status
        final questData = await QuestService.getQuestById(
          userId: userId.toString(),
          questId: widget.questId,
        );

        setState(() {
          _quest = Quest.fromJson(questData);
        });

        // Refresh user to reflect XP/level that backend may have awarded
        await userProvider.refreshUser();

        // If backend did not add XP, fallback to adding XP here
        final reward = _quest?.xpReward ?? 0;
        if (reward > 0 && mounted) {
          final currentUser = context.read<UserProvider>().user;
          if (currentUser != null && currentUser.xp == beforeXp) {
            try {
              await UserService.addXp(
                userId: userId.toString(),
                xpAmount: reward,
              );
              await userProvider.refreshUser();
            } catch (e) {
              print('Failed to add XP via fallback: $e');
            }
          }
        }

        // Level-up detection (compare latest against beforeLevel)
        final afterLevel =
            context.read<UserProvider>().user?.level ?? beforeLevel;
        if (afterLevel > beforeLevel && mounted) {
          _showLevelUpDialog(afterLevel);
        }

        // Show congratulations message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🎉 Quest Completed!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('Earned ${_quest!.xpReward} XP!'),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        print('Error auto-completing quest: $e');
      }
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Level Up! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Congrats! You reached level $newLevel.'),
              const SizedBox(height: 8),
              const Text('Keep going to unlock more rewards!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Awesome'),
            ),
          ],
        );
      },
    );
  }

  // Manual toggle removed; quest completes automatically based on progress.

  Future<void> _deleteQuest() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Quest'),
            content: const Text('Are you sure you want to delete this quest?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await QuestService.deleteQuest(
        userId: userId.toString(),
        questId: widget.questId,
      );

      Navigator.pop(context, true); // Return true to indicate refresh needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete quest: $e')));
    }
  }

  Future<void> _removeExercise(String exerciseId) async {
    // Changed from int to String
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) return;

    try {
      await QuestService.removeExerciseFromQuest(
        userId: userId.toString(),
        questId: widget.questId,
        exerciseId: exerciseId,
      );
      await _loadQuestDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise removed from quest')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove exercise: $e')));
    }
  }

  Future<void> _completeExercise(Map<String, dynamic> exercise) async {
    final isCompleted = exercise['endAt'] != null;
    if (isCompleted) {
      // Already completed
      return;
    }

    final exerciseId = exercise['id'] as String;
    final exerciseName = exercise['exerciseTypeName'] ?? 'Exercise';
    final sets = (exercise['sets'] as int?) ?? 0;
    final repsPerSet = (exercise['repsPerSet'] as int?) ?? 0;
    final weightKg = (exercise['weightKg'] as num?)?.toDouble() ?? 0.0;
    final note = (exercise['note'] as String?) ?? '';

    final setsController = TextEditingController(text: sets.toString());
    final repsController = TextEditingController(text: repsPerSet.toString());
    final weightController = TextEditingController(text: weightKg.toString());
    final noteController = TextEditingController(text: note);

    // Show detail input dialog for completion
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Complete: $exerciseName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps per Set',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final newSets = int.tryParse(setsController.text);
      final newReps = int.tryParse(repsController.text);
      final newWeight = double.tryParse(weightController.text);
      final newNote =
          noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim();

      await ExerciseService.completeExercise(
        exerciseId: exerciseId,
        sets: newSets,
        repsPerSet: newReps,
        weightKg: newWeight,
        note: newNote,
      );

      await _loadQuestDetails();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Exercise completed! 🎉')));
      }

      // Check if all exercises are complete to auto-complete quest
      await _checkAndAutoCompleteQuest();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete exercise: $e')),
        );
      }
    }
  }

  Widget _buildProgressSection() {
    final ratio = _computeProgressRatio();
    final progressPercent = (ratio * 100).toInt();

    print('📊 Progress calculation: $progressPercent%');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '$progressPercent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio == 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return 'N/A';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Details'),
        actions: [
          if (_quest != null && !_quest!.isCompleted) ...[
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteQuest),
          ],
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _quest == null
              ? const Center(child: Text('Quest not found'))
              : RefreshIndicator(
                onRefresh: _loadQuestDetails,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quest Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _quest!.title,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      _quest!.isCompleted
                                          ? 'Completed'
                                          : 'Active',
                                    ),
                                    backgroundColor:
                                        _quest!.isCompleted
                                            ? Colors.green
                                            : Colors.blue,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _quest!.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),

                              // Progress Indicator
                              _buildProgressSection(),

                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(
                                    avatar: const Icon(Icons.flag, size: 18),
                                    label: Text(
                                      'Priority: ${_quest!.priority}',
                                    ),
                                  ),
                                  Chip(
                                    avatar: const Icon(Icons.star, size: 18),
                                    label: Text('${_quest!.xpReward} XP'),
                                  ),
                                  if (_quest!.dueDate != null)
                                    Chip(
                                      avatar: const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                      ),
                                      label: Text('Due: ${_quest!.dueDate}'),
                                    ),
                                  // Target Exercise Types (if any)
                                  if ((_quest!.targetExerciseTypeIds ?? [])
                                      .isNotEmpty)
                                    ..._quest!.targetExerciseTypeIds!.map((id) {
                                      final name = _resolveExerciseTypeName(id);
                                      return Chip(
                                        avatar: const Icon(
                                          Icons.category,
                                          size: 18,
                                        ),
                                        label: Text(
                                          name != null
                                              ? '$name (id:$id)'
                                              : 'Type id:$id',
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress Stats
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              // Aggregate totals from quest or exercises for display
                              Builder(
                                builder: (_) {
                                  int? aggReps;
                                  double? aggWeight;
                                  int? aggDuration;
                                  int? aggSets;
                                  // compute using same helpers as ratio
                                  {
                                    int sumReps = 0;
                                    bool anyReps = false;
                                    for (final raw in _exercises) {
                                      final ex = raw as Map<String, dynamic>;
                                      if (!_includeExerciseForQuestFilters(ex))
                                        continue;
                                      final v = _getTotalReps(ex);
                                      if (v != null && v > 0) {
                                        sumReps += v;
                                        anyReps = true;
                                      }
                                    }
                                    aggReps =
                                        _quest!.totalReps ??
                                        (anyReps ? sumReps : null);

                                    double sumW = 0.0;
                                    bool anyW = false;
                                    for (final raw in _exercises) {
                                      final ex = raw as Map<String, dynamic>;
                                      if (!_includeExerciseForQuestFilters(ex))
                                        continue;
                                      final w = _getTotalWeight(ex);
                                      if (w != null && w > 0) {
                                        sumW += w;
                                        anyW = true;
                                      }
                                    }
                                    aggWeight =
                                        _quest!.totalWeight ??
                                        (anyW ? sumW : null);

                                    int sumD = 0;
                                    bool anyD = false;
                                    for (final raw in _exercises) {
                                      final ex = raw as Map<String, dynamic>;
                                      if (!_includeExerciseForQuestFilters(ex))
                                        continue;
                                      final d = _getDuration(ex);
                                      if (d != null && d > 0) {
                                        sumD += d;
                                        anyD = true;
                                      }
                                    }
                                    aggDuration =
                                        _quest!.duration ??
                                        (anyD ? sumD : null);

                                    int sumS = 0;
                                    bool anyS = false;
                                    for (final raw in _exercises) {
                                      final ex = raw as Map<String, dynamic>;
                                      if (!_includeExerciseForQuestFilters(ex))
                                        continue;
                                      final s = _getSets(ex);
                                      if (s != null && s > 0) {
                                        sumS += s;
                                        anyS = true;
                                      }
                                    }
                                    aggSets =
                                        _quest!.totalSets ??
                                        (anyS ? sumS : null);
                                  }

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatColumn(
                                        context,
                                        'Duration',
                                        _formatDuration(aggDuration),
                                        Icons.timer,
                                      ),
                                      _buildStatColumn(
                                        context,
                                        'Total Sets',
                                        '${aggSets ?? 0}',
                                        Icons.view_array,
                                      ),
                                      _buildStatColumn(
                                        context,
                                        'Total Reps',
                                        '${aggReps ?? 0}',
                                        Icons.fitness_center,
                                      ),
                                      _buildStatColumn(
                                        context,
                                        'Total Weight',
                                        '${(aggWeight ?? 0.0).toStringAsFixed(1)} kg',
                                        Icons.monitor_weight,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // By Exercise Type (breakdown)
                      Builder(
                        builder: (_) {
                          final types = _groupByExerciseType();
                          if (types.isEmpty) return const SizedBox.shrink();
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'By Exercise Type',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  ...types.map((t) {
                                    final completed = t['completed'] as int;
                                    final total = t['total'] as int;
                                    final name =
                                        (t['name'] as String?) ??
                                        'Type #${t['typeId']}';
                                    final ratio =
                                        total > 0 ? completed / total : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                ),
                                              ),
                                              Text('$completed/$total'),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: ratio,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    ratio == 1.0
                                                        ? Colors.green
                                                        : Colors.blue,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 4,
                                            children: [
                                              _miniStat(
                                                Icons.view_array,
                                                '${t['sets'] ?? 0} sets',
                                              ),
                                              _miniStat(
                                                Icons.fitness_center,
                                                '${t['reps'] ?? 0} reps',
                                              ),
                                              _miniStat(
                                                Icons.monitor_weight,
                                                '${(t['weight'] as double).toStringAsFixed(1)} kg',
                                              ),
                                              _miniStat(
                                                Icons.timer,
                                                _formatDuration(
                                                  t['duration'] as int?,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Exercises Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Linked Exercises',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (!_quest!.isCompleted)
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => LinkExerciseToQuestPage(
                                          questId: widget.questId,
                                        ),
                                  ),
                                );
                                if (result == true) _loadQuestDetails();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Exercise'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_exercises.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('No exercises linked to this quest'),
                            ),
                          ),
                        )
                      else
                        ..._exercises.map((exercise) {
                          final isCompleted = exercise['endAt'] != null;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isCompleted ? Colors.green[50] : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    isCompleted ? Colors.green : Colors.blue,
                                child: Icon(
                                  isCompleted
                                      ? Icons.check
                                      : Icons.fitness_center,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercise['exerciseTypeName'] ??
                                          exercise['name'] ??
                                          'Unknown Exercise',
                                      style: TextStyle(
                                        decoration:
                                            isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Planned workout
                                  if (!isCompleted)
                                    Text(
                                      'Plan: ${exercise['sets'] ?? 0} sets × ${exercise['repsPerSet'] ?? 0} reps @ ${exercise['weightKg'] ?? 0} kg',
                                    ),
                                  // Completed workout data
                                  if (isCompleted) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Completed: ${_getTotalReps(exercise) ?? 0} total reps',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.view_array,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sets: ${_getSets(exercise) ?? 0}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.fitness_center,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total Weight: ${(_getTotalWeight(exercise) ?? 0.0).toStringAsFixed(1)} kg',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_getDuration(exercise) ?? 0}s',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (exercise['note'] != null &&
                                      (exercise['note'] as String).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        exercise['note'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isCompleted &&
                                      !(_quest?.isCompleted ?? false))
                                    ElevatedButton.icon(
                                      onPressed:
                                          () => _completeExercise(exercise),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Complete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (!(_quest?.isCompleted ?? false))
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _removeExercise(
                                            exercise['id'] as String,
                                          ), // UUID string
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                      const SizedBox(height: 24),

                      // Manual completion removed; quest auto-completes at 100% progress.
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
