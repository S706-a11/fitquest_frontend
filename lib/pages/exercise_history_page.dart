import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import '../providers/user_provider.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({super.key});

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  List<ExerciseSession> _sessions = [];
  bool _isLoading = true;
  String? _selectedType;
  final List<String> _exerciseTypes = [
    'All',
    'running',
    'cycling',
    'swimming',
    'strength',
    'general',
  ];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userIdInt = int.parse(userId);
      final sessions = await ExerciseService.getUserExerciseSessions(
        userId: userIdInt,
        exerciseType: _selectedType == 'All' ? null : _selectedType,
      );

      setState(() {
        _sessions = sessions.map((s) => ExerciseSession.fromJson(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load sessions: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          'EXERCISE HISTORY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _exerciseTypes.map((type) {
                      final isSelected =
                          _selectedType == type ||
                          (_selectedType == null && type == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.cyan,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type == 'All' ? null : type;
                            });
                            _loadSessions();
                          },
                          selectedColor: Colors.cyan,
                          checkmarkColor: Colors.white,
                          backgroundColor: const Color(0xFF1a1f3a),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // Sessions list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercise sessions yet',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start tracking your workouts!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadSessions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          return _buildSessionCard(_sessions[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ExerciseSession session) {
    final color = _getExerciseColor(session.exerciseType);
    final icon = _getExerciseIcon(session.exerciseType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1a1f3a), const Color(0xFF0d1123)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.exerciseType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(session.completedAt),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (session.questId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'QUEST',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                  Icons.timer,
                  session.getFormattedDuration(),
                  Colors.blue,
                ),
                if (session.distance != null) ...[
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.straighten,
                    session.getFormattedDistance(),
                    Colors.green,
                  ),
                ],
                if (session.distance != null) ...[
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.speed,
                    '${session.getPace()}/km',
                    Colors.orange,
                  ),
                ],
                if (session.calories != null) ...[
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.local_fire_department,
                    '${session.calories} cal',
                    Colors.red,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Colors.orange;
      case 'cycling':
        return Colors.blue;
      case 'swimming':
        return Colors.cyan;
      case 'strength':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  IconData _getExerciseIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      case 'strength':
        return Icons.fitness_center;
      default:
        return Icons.sports;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
