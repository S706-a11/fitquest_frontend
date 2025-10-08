import 'dart:async';
import 'package:flutter/material.dart';

class QuestTrackerPage extends StatefulWidget {
  final String? titleOverride;
  final int? xpOverride;
  const QuestTrackerPage({super.key, this.titleOverride, this.xpOverride});

  @override
  State<QuestTrackerPage> createState() => _QuestTrackerPageState();
}

class _QuestTrackerPageState extends State<QuestTrackerPage> {
  Duration elapsed = Duration.zero;
  Timer? _timer;
  bool running = false;

  void _start() {
    if (running) return;
    setState(() => running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsed += const Duration(seconds: 1));
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      running = false;
      elapsed = Duration.zero;
    });
  }

  String _hhmmss(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.titleOverride ?? 'Morning Run';
    final xp = widget.xpOverride ?? 100;

    return Scaffold(
      appBar: AppBar(title: const Text('QUEST TRACKER')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('$xp XP', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Text(_hhmmss(elapsed), style: const TextStyle(fontSize: 40, letterSpacing: 2)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: running ? null : _start,
                    child: const Text('START'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: running ? _stop : null,
                    child: const Text('STOP'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: _reset, child: const Text('RESET')),
            ),
          ],
        ),
      ),
    );
  }
}
