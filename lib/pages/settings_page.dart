import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_page.dart';
import 'api_test_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Card
              if (user != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : const NetworkImage(
                                    'https://i.pravatar.cc/150?img=1',
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level ${user.level} • ${user.xp} XP',
                          style: const TextStyle(
                            color: Color(0xFF00FF99),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _Tile(label: 'Profile', icon: Icons.person_outline, onTap: () {}),
              _Tile(
                label: 'Notifications',
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              _Tile(
                label: 'Theme',
                icon: Icons.palette_outlined,
                trailing: const Text('Dark'),
                onTap: () {},
              ),
              const Divider(height: 32),
              _Tile(
                label: 'API Connection Test',
                icon: Icons.developer_mode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApiTestPage()),
                  );
                },
              ),
              _Tile(
                label: 'Refresh User Data',
                icon: Icons.refresh,
                onTap: () async {
                  await userProvider.refreshUser();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User data refreshed')),
                    );
                  }
                },
              ),
              const Divider(height: 32),
              _Tile(
                label: 'Logout',
                icon: Icons.logout,
                isDestructive: true,
                onTap: () async {
                  await userProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _Tile({
    required this.label,
    this.icon,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading:
            icon != null
                ? Icon(
                  icon,
                  color: isDestructive ? Colors.red : const Color(0xFF00FF99),
                )
                : null,
        title: Text(
          label,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
