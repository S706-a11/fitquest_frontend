import 'package:flutter/material.dart';
import '../widgets/quest_card.dart';
import 'quest_tracker_page.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = const [
      ('Lifting', 300, 'In Progress'),
      ('Cardio', 200, 'Not Started'),
      ('Morning Run', 100, 'Completed'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('QUESTS'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: quests.length,
        itemBuilder: (_, i) {
          final q = quests[i];
          return QuestCard(
            title: q.$1, xp: q.$2, status: q.$3,
            onTap: () {
              // go to tracker with that quest
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuestTrackerPage(titleOverride: q.$1, xpOverride: q.$2),
              ));
            },
          );
        },
      ),
    );
  }
}
