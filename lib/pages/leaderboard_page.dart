import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ranks = List.generate(8, (i) => ('James', 10 - i, (10000000 - i * 1000)));

    return Scaffold(
      appBar: AppBar(title: const Text('LEADERBOARD')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranks.length,
        itemBuilder: (_, i) {
          final r = ranks[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${i + 2}')),
              title: Text('${r.$1}  ·  Lv-${r.$2}'),
              subtitle: Text('${r.$3} XP'),
              trailing: Text('#${i + 1}'),
            ),
          );
        },
      ),
    );
  }
}
