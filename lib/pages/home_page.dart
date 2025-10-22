import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/xp_bar.dart';
import '../providers/user_provider.dart';
import 'quest_tracker_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🧍 Profile + XP in one box
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        user?.avatarUrl.isNotEmpty == true
                            ? NetworkImage(user!.avatarUrl)
                            : const NetworkImage(
                              'https://api.dicebear.com/9.x/adventurer/svg?seed=Default',
                            ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    user?.displayName ?? 'Adventurer',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Level text
                  Text(
                    'Lv ${user?.level ?? 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  // XP Bar under profile
                  XPBar(
                    xp: user?.xp ?? 0,
                    level: user?.level ?? 1,
                    nextLevelXp: (user?.level ?? 1) * 100,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Quick Start Workout',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _exerciseCard(context, '🏃', 'Running', Colors.blue, 91),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _exerciseCard(
                  context,
                  '🚴',
                  'Cycling',
                  Colors.orange,
                  92,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _exerciseCard(
                  context,
                  '🏊',
                  'Swimming',
                  Colors.teal,
                  93,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Daily Quest',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _progressTile('Daily Quest', .5),
          _progressTile('Newbie Quest', .8),
          _progressTile('Party Quest', .1),
        ],
      ),
    );
  }

  Widget _progressTile(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white10,
                color: const Color(0xFF00FF99),
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

  Widget _exerciseCard(
    BuildContext context,
    String emoji,
    String name,
    Color color,
    int exerciseTypeId,
  ) {
    // Map exercise type ID to exercise type string
    String exerciseType;
    switch (exerciseTypeId) {
      case 91:
        exerciseType = 'running';
        break;
      case 92:
        exerciseType = 'cycling';
        break;
      case 93:
        exerciseType = 'swimming';
        break;
      default:
        exerciseType = 'general';
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => QuestTrackerPage(
                    exerciseType: exerciseType,
                    titleOverride: '$name Workout',
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
