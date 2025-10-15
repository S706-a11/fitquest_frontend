import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../services/session.dart';
import '../../main.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _page = PageController();
  int _index = 0;

  // form state (local only)
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  String _avatar = _avatars.first;
  String _level = 'Beginner';

  static const _avatars = [
    'https://i.pravatar.cc/200?img=11',
    'https://i.pravatar.cc/200?img=12',
    'https://i.pravatar.cc/200?img=13',
    'https://i.pravatar.cc/200?img=14',
    'https://i.pravatar.cc/200?img=15',
    'https://i.pravatar.cc/200?img=16',
  ];

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 3) {
      _page.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) {
      _page.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _finish() {
    final p = Profile(
      displayName: _name.text.trim().isEmpty ? 'Test' : _name.text.trim(),
      avatar: _avatar,
      weightKg: double.tryParse(_weight.text.trim()) ?? 0,
      heightCm: double.tryParse(_height.text.trim()) ?? 0,
      fitnessLevel: _level,
    );
    Session.current = p; // in-memory only
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootShell()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: _back),
        centerTitle: true,
        title: Text(['Welcome','Profile','Metrics','Level'][_index],
          style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // simple progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => _dot(i <= _index, theme)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _WelcomeStep(),
                _ProfileStep(
                  name: _name,
                  avatars: _avatars,
                  selected: _avatar,
                  onSelected: (v) => setState(() => _avatar = v),
                ),
                _MetricsStep(weight: _weight, height: _height),
                _LevelStep(level: _level, onChange: (v) => setState(() => _level = v)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_index < 3 ? 'Next' : 'Finish'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active, ThemeData theme) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: const EdgeInsets.symmetric(horizontal: 4),
    width: active ? 28 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? theme.colorScheme.primary.withOpacity(.9) : Colors.white24,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 12),
        Text('Welcome to FitQuest', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        SizedBox(height: 10),
        Text('Turn workouts into quests. Earn XP, level up, and compete with friends.'),
        SizedBox(height: 16),
        _Feature(icon: Icons.flag, title: 'Daily Quests', desc: 'Complete bite-sized missions every day.'),
        _Feature(icon: Icons.timer, title: 'Tracker', desc: 'Time your workouts and gain XP.'),
        _Feature(icon: Icons.emoji_events, title: 'Leaderboard', desc: 'Climb the ranks!'),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon; final String title; final String desc;
  const _Feature({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(desc)),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  final TextEditingController name;
  final List<String> avatars;
  final String selected;
  final ValueChanged<String> onSelected;
  const _ProfileStep({required this.name, required this.avatars, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Choose your avatar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: avatars.map((a) {
            final isSel = a == selected;
            return GestureDetector(
              onTap: () => onSelected(a),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSel ? const Color(0xFF00FF99) : Colors.white24, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(a, width: 72, height: 72, fit: BoxFit.cover),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Display name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(hintText: 'e.g. Name'), controller: name),
      ],
    );
  }
}

class _MetricsStep extends StatelessWidget {
  final TextEditingController weight;
  final TextEditingController height;
  const _MetricsStep({required this.weight, required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Your metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Weight', suffixText: 'kg'), controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Height', suffixText: 'cm'), controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: 12),
          const Text('You can edit these later in Settings.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  final String level;
  final ValueChanged<String> onChange;
  const _LevelStep({required this.level, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const levels = ['Beginner', 'Advanced', "Godmode"];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose your fitness level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: levels.map((l) {
              final sel = l == level;
              return ChoiceChip(selected: sel, label: Text(l), onSelected: (_) => onChange(l));
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('We’ll tune quests to your level.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
