import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_goal.dart';
import '../models/monthly_goal.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/daily_goal_service.dart';
import '../widgets/xp_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<dynamic> _activeQuests = [];
  bool _isLoadingQuests = true;
  DailyGoal? _latestDailyGoal;
  bool _isLoadingDailyGoal = true;
  String? _dailyGoalError;
  MonthlyGoal? _currentMonthlyGoal;
  bool _isLoadingMonthlyGoal = true;
  String? _monthlyGoalError;
  String? _loadedUserId;
  bool _isRecomputingDailyGoal = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshData() async {
    await _refreshAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.id;
    if (userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      _loadActiveQuests();
      _loadDailyGoal();
      _loadMonthlyGoal();
    }
  }

  Future<void> _refreshAll() async {
    await _loadDailyGoal();
    await _loadMonthlyGoal();
    await _loadActiveQuests();
  }

  Future<void> _loadActiveQuests() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _activeQuests = [];
        _isLoadingQuests = false;
      });
      return;
    }

    setState(() {
      _isLoadingQuests = true;
    });

    try {
      final userId = int.tryParse(user.id);
      if (userId == null) {
        setState(() {
          _activeQuests = [];
          _isLoadingQuests = false;
        });
        debugPrint('User ID is not numeric; skipping quest load');
        return;
      }

      final quests = await ApiService.getActiveQuests(userId);
      if (!mounted) return;
      setState(() {
        _activeQuests = quests;
        _isLoadingQuests = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingQuests = false;
      });
      debugPrint('Error loading quests: $e');
    }
  }

  Future<void> _loadDailyGoal() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _latestDailyGoal = null;
        _isLoadingDailyGoal = false;
        _dailyGoalError = null;
      });
      return;
    }

    if (user.id.isEmpty) {
      setState(() {
        _latestDailyGoal = null;
        _isLoadingDailyGoal = false;
        _dailyGoalError = 'Could not load daily goal';
      });
      return;
    }

    setState(() {
      _isLoadingDailyGoal = true;
      _dailyGoalError = null;
    });

    try {
      final goalsResponse = await ApiService.getDailyGoals();
      final userId = user.id.toLowerCase();
      final goals =
          goalsResponse
              .whereType<Map<String, dynamic>>()
              .map(DailyGoal.fromJson)
              .where(
                (goal) =>
                    goal.userId.isNotEmpty &&
                    goal.userId.toLowerCase() == userId,
              )
              .toList();

      goals.sort((a, b) {
        final aDate = a.dateYmd ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.dateYmd ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      final today = DateTime.now();
      DailyGoal? todaysGoal;
      for (final goal in goals) {
        final goalDate = goal.dateYmd;
        if (goalDate != null && _isSameDay(goalDate, today)) {
          todaysGoal = goal;
          break;
        }
      }

      DailyGoal? goalToDisplay =
          todaysGoal ?? (goals.isNotEmpty ? goals.first : null);

      if (todaysGoal == null) {
        final createdGoal = await _createDailyGoalForToday(user.id);
        if (!mounted) return;
        if (createdGoal != null) {
          goalToDisplay = createdGoal;
        }
      }

      if (!mounted) return;
      setState(() {
        _latestDailyGoal = goalToDisplay;
        _isLoadingDailyGoal = false;
        _dailyGoalError =
            goalToDisplay == null ? 'Could not load daily goal' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dailyGoalError = 'Could not load daily goal';
        _isLoadingDailyGoal = false;
      });
      debugPrint('Error loading daily goal: $e');
    }
  }

  Future<void> _loadMonthlyGoal() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _currentMonthlyGoal = null;
        _isLoadingMonthlyGoal = false;
        _monthlyGoalError = null;
      });
      return;
    }

    if (user.id.isEmpty) {
      setState(() {
        _currentMonthlyGoal = null;
        _isLoadingMonthlyGoal = false;
        _monthlyGoalError = 'Could not load monthly goal';
      });
      return;
    }

    setState(() {
      _isLoadingMonthlyGoal = true;
      _monthlyGoalError = null;
    });

    try {
      final goalsResponse = await ApiService.getMonthlyGoals();
      final userId = user.id.toLowerCase();
      final goals =
          goalsResponse
              .whereType<Map<String, dynamic>>()
              .map(MonthlyGoal.fromJson)
              .where(
                (goal) =>
                    goal.userId.isNotEmpty &&
                    goal.userId.toLowerCase() == userId,
              )
              .toList();

      goals.sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.month.compareTo(a.month);
      });

      final now = DateTime.now();
      MonthlyGoal? matchingGoal;
      for (final goal in goals) {
        if (goal.year == now.year && goal.month == now.month) {
          matchingGoal = goal;
          break;
        }
      }

      if (matchingGoal == null) {
        final createdGoal = await _createMonthlyGoalForCurrentMonth(
          user.id,
          now,
        );
        if (!mounted) return;
        if (createdGoal != null) {
          matchingGoal = createdGoal;
        }
      }

      if (!mounted) return;
      setState(() {
        _currentMonthlyGoal =
            matchingGoal ?? (goals.isNotEmpty ? goals.first : null);
        _isLoadingMonthlyGoal = false;
        _monthlyGoalError =
            _currentMonthlyGoal == null ? 'Could not load monthly goal' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _monthlyGoalError = 'Could not load monthly goal';
        _isLoadingMonthlyGoal = false;
      });
      debugPrint('Error loading monthly goal: $e');
    }
  }

  Future<DailyGoal?> _createDailyGoalForToday(String userId) async {
    try {
      final response = await ApiService.createDailyGoal(
        userId: userId,
        date: DateTime.now(),
        targetMinutes: 60,
        targetReps: 100,
        targetDistanceM: 5000,
      );
      return DailyGoal.fromJson(response);
    } catch (e) {
      debugPrint('Error creating daily goal: $e');
      return null;
    }
  }

  Future<MonthlyGoal?> _createMonthlyGoalForCurrentMonth(
    String userId,
    DateTime now,
  ) async {
    try {
      final response = await ApiService.createMonthlyGoal(
        userId: userId,
        year: now.year,
        month: now.month,
        targetMinutes: 1200,
        targetReps: 2000,
        targetDistanceM: 100000,
      );
      return MonthlyGoal.fromJson(response);
    } catch (e) {
      debugPrint('Error creating monthly goal: $e');
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'HOME',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          body:
              user == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: _refreshAll,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : const NetworkImage(
                                        'https://i.pravatar.cc/150?img=1',
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Lv ${user.level}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        XPBar(
                          xp: user.xp,
                          level: user.level,
                          nextLevelXp: user.nextLevelXp,
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Daily Goal',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingDailyGoal)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_dailyGoalError != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _dailyGoalError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          )
                        else if (_latestDailyGoal == null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No daily goal set yet. Visit the goals section to create one.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        else
                          _dailyGoalCard(_latestDailyGoal!),

                        const SizedBox(height: 24),
                        const Text(
                          'Monthly Goal',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingMonthlyGoal)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_monthlyGoalError != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _monthlyGoalError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          )
                        else if (_currentMonthlyGoal == null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No monthly goal set yet. Visit the goals section to create one.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        else
                          _monthlyGoalCard(_currentMonthlyGoal!),

                        const SizedBox(height: 24),
                        const Text(
                          'Active Quests',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingQuests)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_activeQuests.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No active quests. Go to Quests tab to create one!',
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._activeQuests.map((quest) {
                            final progress = quest['progress'] ?? 0.0;
                            final progressValue =
                                progress is int ? progress / 100.0 : progress;
                            return _progressTile(
                              quest['title'] ?? 'Quest',
                              progressValue is double ? progressValue : 0.0,
                            );
                          }),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _dailyGoalCard(DailyGoal goal) {
    final metrics =
        <Widget?>[
          _goalMetricRow(
            'Minutes',
            goal.progressMinutes,
            goal.targetMinutes,
            unit: 'min',
          ),
          _goalMetricRow('Reps', goal.progressReps, goal.targetReps),
          _goalMetricRow(
            'Distance',
            goal.progressDistanceM,
            goal.targetDistanceM,
            unit: 'm',
          ),
        ].whereType<Widget>().toList();

    final children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Goal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                goal.formattedDate,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(goal.statusLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ];

    if (metrics.isEmpty) {
      children.add(
        const Text(
          'Targets are not set for this goal yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    } else {
      for (var i = 0; i < metrics.length; i++) {
        children.add(metrics[i]);
        if (i < metrics.length - 1) {
          children.add(const SizedBox(height: 12));
        }
      }
    }

    // Add recompute button
    children.add(const SizedBox(height: 12));
    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _isRecomputingDailyGoal
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : ElevatedButton.icon(
                onPressed: () => _recomputeDailyGoalFromExercises(goal),
                icon: const Icon(Icons.refresh),
                label: const Text('Recompute from exercises'),
              ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Future<void> _recomputeDailyGoalFromExercises(DailyGoal goal) async {
    if (_isRecomputingDailyGoal) return;
    setState(() => _isRecomputingDailyGoal = true);
    try {
      final result = await DailyGoalService.recomputeFromExercises(
        goalId: goal.id,
        updateStatus: true,
      );
      // Refresh latest goal
      await _loadDailyGoal();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily goal recomputed${result.isNotEmpty ? ': ${result.toString()}' : ''}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to recompute daily goal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecomputingDailyGoal = false);
    }
  }

  Widget _monthlyGoalCard(MonthlyGoal goal) {
    final metrics =
        <Widget?>[
          _goalMetricRow(
            'Minutes',
            goal.progressMinutes,
            goal.targetMinutes,
            unit: 'min',
          ),
          _goalMetricRow('Reps', goal.progressReps, goal.targetReps),
          _goalMetricRow(
            'Distance',
            goal.progressDistanceM,
            goal.targetDistanceM,
            unit: 'm',
          ),
        ].whereType<Widget>().toList();

    final children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Month\'s Goal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                goal.formattedMonth,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(goal.statusLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ];

    if (metrics.isEmpty) {
      children.add(
        const Text(
          'Targets are not set for this goal yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    } else {
      for (var i = 0; i < metrics.length; i++) {
        children.add(metrics[i]);
        if (i < metrics.length - 1) {
          children.add(const SizedBox(height: 12));
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget? _goalMetricRow(
    String label,
    int progress,
    int target, {
    String? unit,
  }) {
    if (target <= 0) return null;

    final progressLabel = unit != null ? '$progress $unit' : '$progress';
    final targetLabel = unit != null ? '$target $unit' : '$target';
    final progressText = '$progressLabel / $targetLabel';
    final ratio =
        target > 0 ? (progress / target).clamp(0.0, 1.0).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              progressText,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: Colors.white10,
          ),
        ),
      ],
    );
  }

  Widget _progressTile(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
