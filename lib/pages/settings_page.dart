import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/exercise_service.dart';
import 'login_page.dart';
import 'admin/quest_generator_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final user = userProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user data available')));
      return;
    }

    final didUpdate = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) =>
              _EditProfileDialog(initialUser: user, userProvider: userProvider),
    );

    if (didUpdate == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

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
              _Tile(
                label: 'Profile',
                icon: Icons.person_outline,
                onTap: () => _showEditProfileDialog(context, userProvider),
              ),
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
                label: 'Quest Template Generator (Dev)',
                icon: Icons.auto_awesome_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuestGeneratorPage(),
                    ),
                  );
                },
              ),
              _Tile(
                label: 'Generate Exercises (Dev)',
                icon: Icons.auto_fix_high_outlined,
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (_) => const _GenerateExercisesDialog(),
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

class _GenerateExercisesDialog extends StatefulWidget {
  const _GenerateExercisesDialog();

  @override
  State<_GenerateExercisesDialog> createState() =>
      _GenerateExercisesDialogState();
}

class _GenerateExercisesDialogState extends State<_GenerateExercisesDialog> {
  bool _generateExerciseTypes = true;
  bool _includeNotes = true;
  final TextEditingController _exerciseTypeCountCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _exercisesPerUserCtrl = TextEditingController(
    text: '0',
  );
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _exerciseTypeCountCtrl.dispose();
    _exercisesPerUserCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final typeCount = int.tryParse(_exerciseTypeCountCtrl.text.trim()) ?? 0;
    final perUser = int.tryParse(_exercisesPerUserCtrl.text.trim()) ?? 0;

    try {
      final res = await ExerciseService.generateExercises(
        generateExerciseTypes: _generateExerciseTypes,
        exerciseTypeCount: typeCount,
        exercisesPerUser: perUser,
        includeNotes: _includeNotes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Generation complete: ${res.isEmpty ? 'OK' : 'OK (' + res.keys.join(', ') + ')'}',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Exercises (Dev)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guidance
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guide: Generate Exercise Types',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Use this tool to seed default exercise types or create sample exercises for users. '
                    'Turn ON "Generate Exercise Types" and set counts to 0 to create a sensible default set.',
                  ),
                  SizedBox(height: 8),
                  Text('Example payload:'),
                  SizedBox(height: 4),
                  SelectableText(
                    '{\n  "generateExerciseTypes": true,\n  "exerciseTypeCount": 0,\n  "exercisesPerUser": 0,\n  "includeNotes": true\n}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Generate Exercise Types'),
              subtitle: const Text(
                'Creates default exercise type catalog when enabled',
              ),
              value: _generateExerciseTypes,
              onChanged: (v) => setState(() => _generateExerciseTypes = v),
            ),
            TextField(
              controller: _exerciseTypeCountCtrl,
              decoration: const InputDecoration(
                labelText: 'Exercise Type Count (0 = default)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _exercisesPerUserCtrl,
              decoration: const InputDecoration(
                labelText: 'Exercises Per User (0 = default)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include Notes'),
              value: _includeNotes,
              onChanged: (v) => setState(() => _includeNotes = v),
            ),
            const SizedBox(height: 8),
            // Preset quick action
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed:
                    _submitting
                        ? null
                        : () {
                          setState(() {
                            _generateExerciseTypes = true;
                            _exerciseTypeCountCtrl.text = '0';
                            _exercisesPerUserCtrl.text = '0';
                            _includeNotes = true;
                          });
                          _submit();
                        },
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Generate Exercise Types Only'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child:
              _submitting
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Generate'),
        ),
      ],
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final User initialUser;
  final UserProvider userProvider;

  const _EditProfileDialog({
    required this.initialUser,
    required this.userProvider,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _avatarController;
  late final TextEditingController _levelController;
  late final TextEditingController _xpController;
  late final TextEditingController _streakController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _passwordController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = widget.userProvider.user ?? widget.initialUser;
    _displayNameController = TextEditingController(text: user.displayName);
    _avatarController = TextEditingController(text: user.avatarUrl ?? '');
    _levelController = TextEditingController(text: user.level.toString());
    _xpController = TextEditingController(text: user.xp.toString());
    _streakController = TextEditingController(
      text: user.streakCount.toString(),
    );
    _weightController = TextEditingController(
      text:
          user.weightKg != null && user.weightKg! > 0
              ? user.weightKg!.toString()
              : '',
    );
    _heightController = TextEditingController(
      text:
          user.heightCm != null && user.heightCm! > 0
              ? user.heightCm!.toString()
              : '',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarController.dispose();
    _levelController.dispose();
    _xpController.dispose();
    _streakController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final currentUser = widget.userProvider.user ?? widget.initialUser;

    final displayNameInput = _displayNameController.text.trim();
    final avatarInput = _avatarController.text.trim();
    final levelInput = _levelController.text.trim();
    final xpInput = _xpController.text.trim();
    final streakInput = _streakController.text.trim();
    final weightInput = _weightController.text.trim();
    final heightInput = _heightController.text.trim();
    final passwordInput = _passwordController.text.trim();

    final levelValue = levelInput.isEmpty ? null : int.tryParse(levelInput);
    final xpValue = xpInput.isEmpty ? null : int.tryParse(xpInput);
    final streakValue = streakInput.isEmpty ? null : int.tryParse(streakInput);
    final weightValue =
        weightInput.isEmpty ? null : double.tryParse(weightInput);
    final heightValue =
        heightInput.isEmpty ? null : double.tryParse(heightInput);

    final hasInvalidNumericInput =
        (levelInput.isNotEmpty && levelValue == null) ||
        (xpInput.isNotEmpty && xpValue == null) ||
        (streakInput.isNotEmpty && streakValue == null) ||
        (weightInput.isNotEmpty && weightValue == null) ||
        (heightInput.isNotEmpty && heightValue == null);

    if (hasInvalidNumericInput) {
      setState(() => _errorMessage = 'Enter valid numeric values');
      return;
    }

    final displayNameUpdate =
        displayNameInput.isEmpty || displayNameInput == currentUser.displayName
            ? null
            : displayNameInput;
    final avatarUpdate =
        avatarInput != (currentUser.avatarUrl ?? '') ? avatarInput : null;
    final levelUpdate =
        levelValue != null && levelValue != currentUser.level
            ? levelValue
            : null;
    final xpUpdate =
        xpValue != null && xpValue != currentUser.xp ? xpValue : null;
    final streakUpdate =
        streakValue != null && streakValue != currentUser.streakCount
            ? streakValue
            : null;
    final weightUpdate =
        weightValue != null &&
                (currentUser.weightKg == null ||
                    weightValue != currentUser.weightKg)
            ? weightValue
            : null;
    final heightUpdate =
        heightValue != null &&
                (currentUser.heightCm == null ||
                    heightValue != currentUser.heightCm)
            ? heightValue
            : null;
    final passwordUpdate = passwordInput.isNotEmpty ? passwordInput : null;

    final hasChanges =
        displayNameUpdate != null ||
        avatarUpdate != null ||
        levelUpdate != null ||
        xpUpdate != null ||
        streakUpdate != null ||
        weightUpdate != null ||
        heightUpdate != null ||
        passwordUpdate != null;

    if (!hasChanges) {
      setState(() => _errorMessage = 'No changes to update');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);

    try {
      final response = await ApiService.updateUser(
        userId: currentUser.id,
        displayName: displayNameUpdate,
        avatarUrl: avatarUpdate,
        level: levelUpdate,
        xp: xpUpdate,
        streakCount: streakUpdate,
        weightKg: weightUpdate,
        heightCm: heightUpdate,
        password: passwordUpdate,
      );

      if (response.isNotEmpty) {
        widget.userProvider.setUser(User.fromJson(response));
      } else {
        await widget.userProvider.refreshUser();
      }

      if (navigator.mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update profile: $e';
        });
        print('Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Level'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _xpController,
              decoration: const InputDecoration(labelText: 'XP'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _streakController,
              decoration: const InputDecoration(labelText: 'Streak Count'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSaving ? null : _saveProfile,
          child:
              _isSaving
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save'),
        ),
      ],
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
