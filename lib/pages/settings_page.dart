import 'package:flutter/material.dart';
import 'profile_settings_page.dart';
import 'api_test_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTING',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            label: 'Profile',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsPage(),
                  ),
                ),
          ),
          const _Tile(label: 'Notification'),
          const _Tile(label: 'Theme', trailing: Text('Dark')),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Developer Tools',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _Tile(
            label: 'API Connection Test',
            trailing: const Icon(Icons.bug_report, color: Colors.orange),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiTestPage()),
                ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
