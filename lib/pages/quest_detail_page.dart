import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
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
    } catch (e) {
      print('Error loading quest details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleQuestStatus() async {
    if (_quest == null) return;

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) return;

    try {
      await QuestService.toggleQuestStatus(
        userId: userId,
        questId: widget.questId,
      );
      await _loadQuestDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _quest!.isCompleted ? 'Quest marked as active' : 'Quest completed!',
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
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.fitness_center),
                              ),
                              title: Text(
                                exercise['name'] ?? 'Unknown Exercise',
                              ),
                              subtitle: Text(
                                '${exercise['sets'] ?? 0} sets × ${exercise['reps'] ?? 0} reps @ ${exercise['weight'] ?? 0} kg',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _removeExercise(
                                      exercise['id'] as String,
                                    ), // UUID string
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
