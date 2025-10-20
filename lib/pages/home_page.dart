import 'package:flutter/material.dart';
import '../widgets/xp_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=1'),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  const Text(
                    'James',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  // Level text
                  const Text(
                    'Lv-1',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  // XP Bar under profile
                  const XPBar(xp: 50, level: 1, nextLevelXp: 100),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Daily Quest',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.white)),
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
}
