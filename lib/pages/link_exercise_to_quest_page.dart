import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exercise_service.dart';
import '../services/quest_service.dart';
import '../providers/user_provider.dart';

class LinkExerciseToQuestPage extends StatefulWidget {
  final int questId;

  const LinkExerciseToQuestPage({Key? key, required this.questId})
    : super(key: key);

  @override
  State<LinkExerciseToQuestPage> createState() =>
      _LinkExerciseToQuestPageState();
}

class _LinkExerciseToQuestPageState extends State<LinkExerciseToQuestPage> {
  List<dynamic> _allExercises = [];
  List<dynamic> _filteredExercises = [];
  List<int> _selectedExerciseIds = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userIdInt = int.parse(userId);
      final exercises = await ExerciseService.getUserExercises(userIdInt);

      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exercises: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load exercises: $e')));
    }
  }

  void _filterExercises(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises =
            _allExercises.where((exercise) {
              final name = (exercise['name'] as String?)?.toLowerCase() ?? '';
              final description =
                  (exercise['description'] as String?)?.toLowerCase() ?? '';
              final searchLower = query.toLowerCase();
              return name.contains(searchLower) ||
                  description.contains(searchLower);
            }).toList();
      }
    });
  }

  Future<void> _linkExercises() async {
    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;
    if (userId == null) return;

    try {
      final userIdInt = int.parse(userId);

      // Link each selected exercise
      for (final exerciseId in _selectedExerciseIds) {
        await QuestService.addExerciseToQuest(
          userId: userIdInt,
          questId: widget.questId,
          exerciseId: exerciseId,
        );
      }

      Navigator.pop(context, true); // Return true to indicate refresh needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedExerciseIds.length} exercise(s) linked successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to link exercises: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Exercises'),
        actions: [
          if (_selectedExerciseIds.isNotEmpty)
            TextButton.icon(
              onPressed: _linkExercises,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Link (${_selectedExerciseIds.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterExercises,
            ),
          ),

          // Exercise List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredExercises.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No exercises available'
                                : 'No exercises found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _filteredExercises[index];
                        final exerciseId = exercise['id'] as int;
                        final isSelected = _selectedExerciseIds.contains(
                          exerciseId,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? Colors.blue[50] : null,
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedExerciseIds.add(exerciseId);
                                } else {
                                  _selectedExerciseIds.remove(exerciseId);
                                }
                              });
                            },
                            title: Text(
                              exercise['name'] ?? 'Unknown Exercise',
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercise['description'] != null &&
                                    (exercise['description'] as String)
                                        .isNotEmpty)
                                  Text(
                                    exercise['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise['sets'] ?? 0} sets × ${exercise['reps'] ?? 0} reps @ ${exercise['weight'] ?? 0} kg',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            secondary: CircleAvatar(
                              backgroundColor:
                                  isSelected ? Colors.blue : Colors.grey[300],
                              child: Icon(
                                Icons.fitness_center,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedExerciseIds.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _linkExercises,
                icon: const Icon(Icons.link),
                label: Text('Link ${_selectedExerciseIds.length} Exercise(s)'),
              )
              : null,
    );
  }
}
