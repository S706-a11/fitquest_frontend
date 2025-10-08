import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final String title;
  final int xp;
  final String status; // 'Not Started' | 'In Progress' | 'Completed'
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.title,
    required this.xp,
    required this.status,
    this.onTap,
  });

  Color _statusColor() {
    switch (status) {
      case 'In Progress': return const Color(0xFF3B82F6);
      case 'Completed': return const Color(0xFF10B981);
      default: return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('$xp XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(fontSize: 12, color: _statusColor())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
