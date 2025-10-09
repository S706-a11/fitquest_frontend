import 'package:flutter/material.dart';
import '../widgets/xp_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background, elevation: 0,
        centerTitle: true,
        title: const Text('HOME',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2,),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('James', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('Lv-1', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const XPBar(xp: 50, level: 1, nextLevelXp: 100),

          const SizedBox(height: 24),
          const Text('Daily Quest', style: TextStyle(fontWeight: FontWeight.w700)),
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
            Text(title),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: value, minHeight: 10, backgroundColor: Colors.white10),
            ),
            const SizedBox(height: 4),
            Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
