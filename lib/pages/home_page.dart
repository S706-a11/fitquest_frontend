import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/xp_bar.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _activeQuests = [];
  bool _isLoadingQuests = true;

  @override
  void initState() {
    super.initState();
    _loadActiveQuests();
  }

  Future<void> _loadActiveQuests() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      try {
        final quests = await ApiService.getActiveQuests(userProvider.user!.id);
        setState(() {
          _activeQuests = quests;
          _isLoadingQuests = false;
        });
      } catch (e) {
        setState(() => _isLoadingQuests = false);
        print('Error loading quests: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
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
                  : ListView(
                    padding: const EdgeInsets.all(16),
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
                        }).toList(),
                    ],
                  ),
        );
      },
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
