import 'package:flutter/material.dart';

class XPBar extends StatelessWidget {
  final int xp;
  final int level;
  final int nextLevelXp;
  const XPBar({super.key, required this.xp, required this.level, required this.nextLevelXp});

  @override
  Widget build(BuildContext context) {
    final pct = (xp / nextLevelXp).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lv-$level  •  ${xp}/${nextLevelXp} XP', style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: Colors.white10,
          ),
        ),
      ],
    );
  }
}
