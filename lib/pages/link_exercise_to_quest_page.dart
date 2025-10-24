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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
      }
      return;
    }

    try {
      final userIdInt = int.parse(userId);
      print('Loading exercises for user: $userIdInt');
      final exercises = await ExerciseService.getUserExercises(userIdInt);
      print('Loaded ${exercises.length} exercises');

      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exercises: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exercises: $e'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Retry', onPressed: _loadExercises),
          ),
        );
      }
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
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Linking exercises...'),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      print(
        'Linking ${_selectedExerciseIds.length} exercises to quest ${widget.questId}',
      );

      // Link each selected exercise
      for (final exerciseId in _selectedExerciseIds) {
        print('Linking exercise $exerciseId to quest ${widget.questId}');
        await QuestService.addExerciseToQuest(
          userId: userId,
          questId: widget.questId,
          exerciseId: exerciseId,
        );
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Close this page and return success
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedExerciseIds.length} exercise(s) linked successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error linking exercises: $e');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to link exercises: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _linkExercises,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showCreateExerciseDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final repsController = TextEditingController(text: '10');
    final setsController = TextEditingController(text: '3');
    final weightController = TextEditingController(text: '0');
    String selectedType = 'strength';

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Create Exercise'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Exercise Name *',
                            hintText: 'e.g., Push-ups, Squats',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Exercise Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'strength',
                              child: Text('Strength Training'),
                            ),
                            DropdownMenuItem(
                              value: 'cardio',
                              child: Text('Cardio'),
                            ),
                            DropdownMenuItem(
                              value: 'running',
                              child: Text('Running'),
                            ),
                            DropdownMenuItem(
                              value: 'cycling',
                              child: Text('Cycling'),
                            ),
                            DropdownMenuItem(
                              value: 'swimming',
                              child: Text('Swimming'),
                            ),
                            DropdownMenuItem(
                              value: 'general',
                              child: Text('General'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'Add notes about this exercise',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: setsController,
                                decoration: const InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: repsController,
                                decoration: const InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter exercise name'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true) {
      await _createExercise(
        nameController.text.trim(),
        selectedType,
        descriptionController.text.trim(),
        int.tryParse(repsController.text) ?? 10,
        int.tryParse(setsController.text) ?? 3,
        double.tryParse(weightController.text) ?? 0,
      );
    }

    nameController.dispose();
    descriptionController.dispose();
    repsController.dispose();
    setsController.dispose();
    weightController.dispose();
  }

  Future<void> _createExercise(
    String name,
    String exerciseType,
    String description,
    int reps,
    int sets,
    double weight,
  ) async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) return;

    try {
      final userIdInt = int.parse(userId);

      await ExerciseService.createExercise(
        userId: userIdInt,
        name: name,
        exerciseType: exerciseType,
        description: description.isNotEmpty ? description : null,
        reps: reps,
        weight: weight,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise created successfully!')),
      );

      // Reload exercises
      _loadExercises();
    } catch (e) {
      print('Error creating exercise: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create exercise: $e')));
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
                            _searchQuery.isEmpty
                                ? Icons.fitness_center
                                : Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No exercises available'
                                : 'No exercises found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Create an exercise first to link it to this quest'
                                : 'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateExerciseDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Exercise'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
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
              : FloatingActionButton.extended(
                onPressed: _showCreateExerciseDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Exercise'),
                backgroundColor: Colors.green,
              ),
    );
  }
}
