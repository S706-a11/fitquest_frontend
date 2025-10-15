import 'package:flutter/material.dart';
import '../services/session.dart';
import '../models/profile.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final TextEditingController _name;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late String _avatar;
  String _level = 'Beginner';

  static const _avatars = [
    'https://api.dicebear.com/9.x/adventurer/svg?seed=Alex',
    'https://api.dicebear.com/9.x/adventurer/svg?seed=Jamie',
  ];

  @override
  void initState() {
    super.initState();
    final p = Session.orDefault;
    _name = TextEditingController(text: p.displayName);
    _weight = TextEditingController(text: p.weightKg > 0 ? p.weightKg.toString() : '');
    _height = TextEditingController(text: p.heightCm > 0 ? p.heightCm.toString() : '');
    _avatar = p.avatar.isNotEmpty ? p.avatar : _avatars.first;
    _level = p.fitnessLevel;
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim().isEmpty ? 'Adventurer' : _name.text.trim();
    final weight = double.tryParse(_weight.text.trim()) ?? 0;
    final height = double.tryParse(_height.text.trim()) ?? 0;

    Session.current = Profile(
      displayName: name,
      avatar: _avatar,
      weightKg: weight,
      heightCm: height,
      fitnessLevel: _level,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // optional 
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFF1E1E1E),
                width: 120,
                height: 120,
                child: Image.network(_avatar, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Tap an avatar below to change', style: TextStyle(color: Colors.white70))),

          const SizedBox(height: 12),
          // grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _avatars.map((a) {
              final sel = a == _avatar;
              return GestureDetector(
                onTap: () => setState(() => _avatar = a),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? const Color(0xFF00FF99) : Colors.white24, width: 2),
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
          const Text('Display name', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'e.g. James'),
          ),

          const SizedBox(height: 16),
          const Text('Metrics', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Weight', suffixText: 'kg'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Height', suffixText: 'cm'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Fitness level', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
              final sel = l == _level;
              return ChoiceChip(
                selected: sel,
                label: Text(l),
                onSelected: (_) => setState(() => _level = l),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}


//must need 1-add upload user pic 2-change password/gmail 3- delete account 4- logout