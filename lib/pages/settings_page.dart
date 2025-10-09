import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTING',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2,),
        ),),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Tile(label: 'Profile'),
          _Tile(label: 'Notification'),
          _Tile(label: 'Theme', trailing: Text('Dark')),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _Tile({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

