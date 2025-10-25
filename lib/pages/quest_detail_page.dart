import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../services/exercise_service.dart';
import '../providers/user_provider.dart';
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
        userId: userId,
        questId: widget.questId,
      );
      final exercises = await QuestService.getQuestExercises(
        userId: userId,
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

    // Check if there are exercises and all are completed
    if (_exercises.isEmpty) return;

    final completedCount = _exercises.where((ex) => ex['endAt'] != null).length;
    final totalCount = _exercises.length;

    // If all exercises are completed and quest is not yet marked complete
    if (completedCount == totalCount && completedCount > 0) {
      print('All exercises completed! Auto-completing quest...');

      final userProvider = context.read<UserProvider>();
      final userId = userProvider.user?.id;
      if (userId == null) return;

      try {
        await QuestService.toggleQuestStatus(
          userId: userId,
          questId: widget.questId,
          completed: true, // Explicitly mark as completed
        );

        // Reload to get updated quest status
        final questData = await QuestService.getQuestById(
          userId: userId,
          questId: widget.questId,
        );

        setState(() {
          _quest = Quest.fromJson(questData);
        });

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

  Future<void> _toggleQuestStatus() async {
    if (_quest == null) return;

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) return;

    try {
      // Toggle to the opposite of current status
      final newStatus = !_quest!.isCompleted;

      await QuestService.toggleQuestStatus(
        userId: userId,
        questId: widget.questId,
        completed: newStatus,
      );
      await _loadQuestDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Quest completed!' : 'Quest marked as active',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quest status: $e')),
      );
    }
  }

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
      await QuestService.deleteQuest(userId: userId, questId: widget.questId);

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
        userId: userId,
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
    // Count completed exercises (those with endAt timestamp)
    final completedCount = _exercises.where((ex) => ex['endAt'] != null).length;
    final totalCount = _exercises.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPercent = (progress * 100).toInt();

    print('📊 Progress calculation:');
    print('   Total exercises: $totalCount');
    print('   Completed exercises: $completedCount');
    print('   Progress: $progressPercent%');

    // Debug: Print each exercise's completion status
    for (var i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      print(
        '   Exercise ${i + 1}: ${ex['exerciseTypeName']} - endAt: ${ex['endAt']}',
      );
    }

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
              '$completedCount / $totalCount exercises ($progressPercent%)',
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
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : Colors.blue,
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
          if (_quest != null) ...[
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    context,
                                    'Duration',
                                    _formatDuration(_quest!.duration),
                                    Icons.timer,
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'Total Reps',
                                    '${_quest!.totalReps ?? 0}',
                                    Icons.fitness_center,
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'Total Weight',
                                    '${_quest!.totalWeight ?? 0} kg',
                                    Icons.monitor_weight,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                                          'Completed: ${exercise['totalReps'] ?? 0} total reps',
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
                                          Icons.fitness_center,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total Weight: ${(exercise['totalWeight'] ?? 0).toStringAsFixed(1)} kg',
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
                                          '${exercise['duration'] ?? 0}s',
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
                                  if (!isCompleted)
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

                      // Toggle Complete Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleQuestStatus,
                          icon: Icon(
                            _quest!.isCompleted
                                ? Icons.replay
                                : Icons.check_circle,
                          ),
                          label: Text(
                            _quest!.isCompleted
                                ? 'Mark as Active'
                                : 'Complete Quest',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _quest!.isCompleted
                                    ? Colors.orange
                                    : Colors.green,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
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
}
