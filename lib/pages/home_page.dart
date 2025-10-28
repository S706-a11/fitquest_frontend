import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_goal.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
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
  String? _loadedUserId;

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
    }
  }

  Future<void> _refreshAll() async {
    await _loadDailyGoal();
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
      final goals = goalsResponse
          .whereType<Map<String, dynamic>>()
          .map(DailyGoal.fromJson)
          .where((goal) =>
              goal.userId.isNotEmpty &&
              goal.userId.toLowerCase() == userId)
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

      DailyGoal? goalToDisplay = todaysGoal ?? (goals.isNotEmpty ? goals.first : null);

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
        _dailyGoalError = goalToDisplay == null ? 'Could not load daily goal' : null;
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
    final metrics = <Widget?>[
      _goalMetricRow('Minutes', goal.progressMinutes, goal.targetMinutes, unit: 'min'),
      _goalMetricRow('Reps', goal.progressReps, goal.targetReps),
      _goalMetricRow('Distance', goal.progressDistanceM, goal.targetDistanceM, unit: 'm'),
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
            child: Text(
              goal.statusLabel,
              style: const TextStyle(fontSize: 12),
            ),
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

  Widget? _goalMetricRow(String label, int progress, int target, {String? unit}) {
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
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
