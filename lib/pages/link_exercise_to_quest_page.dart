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
  List<String> _selectedExerciseIds =
      []; // Changed from List<int> to List<String> for UUID
  List<dynamic> _exerciseTypes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _initialized = false;

  // Note: We now send ExerciseTypeId to the backend, so no string mapping is required.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadExerciseTypes();
      _loadExercises();
    }
  }

  Future<void> _loadExerciseTypes() async {
    try {
      final types = await ExerciseService.getExerciseTypes();
      if (mounted) {
        setState(() {
          _exerciseTypes = types;
        });
        print('Loaded ${types.length} exercise types from API');
      }
    } catch (e) {
      print('Error loading exercise types: $e');
      if (mounted) {
        // Set default types if API fails
        setState(() {
          _exerciseTypes = [
            {'id': 1, 'name': 'Strength', 'category': 'strength'},
            {'id': 2, 'name': 'Cardio', 'category': 'cardio'},
            {'id': 3, 'name': 'Running', 'category': 'running'},
            {'id': 4, 'name': 'Cycling', 'category': 'cycling'},
            {'id': 5, 'name': 'Swimming', 'category': 'swimming'},
            {'id': 6, 'name': 'Flexibility', 'category': 'flexibility'},
            {'id': 7, 'name': 'General', 'category': 'general'},
          ];
        });
      }
    }
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
      print('Loading exercises for user: $userId');
      final exercises = await ExerciseService.getUserExercises(userId);
      print('Loaded ${exercises.length} exercises');

      // Debug: Print each exercise to see which one has the issue
      for (var i = 0; i < exercises.length; i++) {
        print('Exercise $i: ${exercises[i]}');
      }

      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading exercises: $e');
      print('Stack trace: $stackTrace');
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
    if (_exerciseTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading exercise types...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show modern exercise selection dialog
    final selectedExerciseType = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) =>
              _ExerciseTypeSelectionDialog(exerciseTypes: _exerciseTypes),
    );

    if (selectedExerciseType == null) return;

    // Create exercise immediately with minimal info (details will be set at completion)
    await _createExercise(selectedExerciseType['id'] as int);
  }

  Future<void> _createExercise(int exerciseTypeId) async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    print('=== CREATE EXERCISE DEBUG ===');
    print('userId: $userId (type: ${userId.runtimeType})');
    print(
      'exerciseTypeId: $exerciseTypeId (type: ${exerciseTypeId.runtimeType})',
    );

    if (userId == null) {
      print('ERROR: userId is null!');
      return;
    }

    try {
      print('Calling ExerciseService.createExercise...');
      final created = await ExerciseService.createExercise(
        userId: userId,
        exerciseTypeId: exerciseTypeId,
      );
      print('Exercise created successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload and auto-select the newly created exercise if ID is present
      await _loadExercises();
      final newId = created['id'] as String?;
      if (newId != null) {
        setState(() {
          _selectedExerciseIds.add(newId);
        });
      }
    } catch (e, stackTrace) {
      print('ERROR creating exercise: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteExercise(
    String exerciseId,
    String exerciseName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Exercise'),
            content: Text('Are you sure you want to delete "$exerciseName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _deleteExercise(exerciseId);
    }
  }

  Future<void> _deleteExercise(String exerciseId) async {
    try {
      print('Deleting exercise: $exerciseId');
      await ExerciseService.deleteExercise(exerciseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Remove from selected list if it was selected
      _selectedExerciseIds.remove(exerciseId);

      // Reload exercises
      _loadExercises();
    } catch (e) {
      print('ERROR deleting exercise: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                        final exerciseId =
                            exercise['id'] as String; // UUID string
                        final isSelected = _selectedExerciseIds.contains(
                          exerciseId,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? Colors.blue[50] : null,
                          child: ListTile(
                            leading: Checkbox(
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
                            ),
                            title: Text(
                              exercise['exerciseTypeName'] ??
                                  exercise['name'] ??
                                  'Unknown Exercise',
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _confirmDeleteExercise(
                                    exerciseId,
                                    exercise['exerciseTypeName'] ?? 'Exercise',
                                  ),
                              tooltip: 'Delete exercise',
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

// Modern Exercise Type Selection Dialog with Search
class _ExerciseTypeSelectionDialog extends StatefulWidget {
  final List<dynamic> exerciseTypes;

  const _ExerciseTypeSelectionDialog({required this.exerciseTypes});

  @override
  State<_ExerciseTypeSelectionDialog> createState() =>
      _ExerciseTypeSelectionDialogState();
}

class _ExerciseTypeSelectionDialogState
    extends State<_ExerciseTypeSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredTypes = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredTypes = widget.exerciseTypes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises(String query) {
    setState(() {
      _filteredTypes =
          widget.exerciseTypes.where((type) {
            final name = type['name']?.toString().toLowerCase() ?? '';
            final description =
                type['description']?.toString().toLowerCase() ?? '';
            final searchLower = query.toLowerCase();
            final matchesSearch =
                name.contains(searchLower) || description.contains(searchLower);

            if (_selectedCategory == 'All') return matchesSearch;

            final category = type['category']?.toString() ?? '0';
            return matchesSearch &&
                _getCategoryName(category) == _selectedCategory;
          }).toList();
    });
  }

  String _getCategoryName(String category) {
    switch (category) {
      case '1':
        return 'Strength';
      case '2':
        return 'Flexibility';
      case '3':
        return 'Cardio';
      default:
        return 'Other';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '1':
        return Colors.red;
      case '2':
        return Colors.purple;
      case '3':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1f3a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.purple.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELECT EXERCISE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose from available exercises',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0d1123),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.cyan[300]),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.red[300]),
                            onPressed: () {
                              _searchController.clear();
                              _filterExercises('');
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: const Color(0xFF1a1f3a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                ),
                onChanged: _filterExercises,
              ),
            ),

            // Category Filters
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All', Colors.grey),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Strength', Colors.red),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Cardio', Colors.blue),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Flexibility', Colors.purple),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Other', Colors.orange),
                ],
              ),
            ),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.cyan[300]),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredTypes.length} exercise${_filteredTypes.length != 1 ? 's' : ''} found',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            // Exercise List
            Expanded(
              child:
                  _filteredTypes.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NO EXERCISES FOUND',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term or category',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTypes.length,
                        itemBuilder: (context, index) {
                          final type = _filteredTypes[index];
                          final name = type['name']?.toString() ?? 'Unknown';
                          final icon = type['icon']?.toString() ?? '💪';
                          final description =
                              type['description']?.toString() ?? '';
                          final category = type['category']?.toString() ?? '0';
                          final categoryName = _getCategoryName(category);
                          final categoryColor = _getCategoryColor(category);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1a1f3a),
                                  const Color(0xFF0d1123),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context, type),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            categoryColor,
                                            categoryColor.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        icon,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: categoryColor.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: categoryColor
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            child: Text(
                                              categoryName.toUpperCase(),
                                              style: TextStyle(
                                                color: categoryColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: categoryColor.withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    final isSelected = _selectedCategory == label;
    return FilterChip(
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = label;
          _filterExercises(_searchController.text);
        });
      },
      backgroundColor: const Color(0xFF1a1f3a),
      selectedColor: color,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// Exercise Details Dialog
// Removed _ExerciseDetailsDialog: creation is now minimal; details are entered at completion time.
