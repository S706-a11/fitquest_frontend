import 'package:flutter/material.dart';
import '../services/user_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<dynamic>> _leaderboardFuture;
  String _metric = 'level';
  int _limit = 50;

  @override
  void initState() {
    super.initState();
  _leaderboardFuture = UserService.getLeaderboard(metric: _metric, limit: _limit);
  }

  String _displayName(Map<String, dynamic> item) {
    return (item['displayName'] ?? item['name'] ?? item['username'] ?? item['email'] ?? 'Unknown').toString();
  }

  int _level(Map<String, dynamic> item) {
    final v = item['level'] ?? item['lvl'] ?? item['Level'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  int _xp(Map<String, dynamic> item) {
    final v = item['xp'] ?? item['xpTotal'] ?? item['points'] ?? item['score'];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String? _avatar(Map<String, dynamic> item) {
    return (item['avatarUrl'] ?? item['avatar'] ?? item['photoUrl'])?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _leaderboardFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load leaderboard: ${snap.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _leaderboardFuture = UserService.getLeaderboard()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No leaderboard data'));
          }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Metric: '),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _metric,
                        items: const [
                          DropdownMenuItem(value: 'level', child: Text('Level')),
                          DropdownMenuItem(value: 'xp', child: Text('XP')),
                          DropdownMenuItem(value: 'streak', child: Text('Streak')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _metric = v;
                            _leaderboardFuture = UserService.getLeaderboard(metric: _metric, limit: _limit);
                          });
                        },
                      ),
                      const Spacer(),
                      const Text('Limit:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _limit,
                        items: const [10, 25, 50, 100].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _limit = v;
                            _leaderboardFuture = UserService.getLeaderboard(metric: _metric, limit: _limit);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final raw = list[i];
                      final item = raw is Map<String, dynamic> ? raw : (raw as dynamic).toJson?.call() ?? {} as Map<String, dynamic>;
                      final rank = item['rank'] ?? (i + 1);
                      final userMap = item['user'] is Map ? item['user'] as Map<String, dynamic> : (item['user'] != null ? (item['user'] as dynamic).toJson?.call() ?? {} as Map<String, dynamic> : <String, dynamic>{});
                      final name = _displayName(userMap);
                      final level = item['level'] ?? item['Level'] ?? _level(userMap);
                      final xp = item['xp'] ?? item['Xp'] ?? _xp(userMap);
                      final streak = item['streakCount'] ?? item['streak'] ?? item['StreakCount'] ?? 0;
                      final score = item['score'] ?? item['Score'] ?? (item[_metric] ?? xp ?? 0);
                      final avatar = _avatar(userMap);

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: avatar != null && avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : NetworkImage('https://i.pravatar.cc/150?img=${(i % 70) + 1}'),
                          ),
                          title: Text('$name  ·  Lv-$level'),
                          subtitle: Text('$xp XP · Streak: $streak'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('$score', style: const TextStyle(fontSize: 12)),
                              Text(_metric.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
        },
      ),
    );
  }
}
