import 'package:flutter/material.dart';
import '../../services/quest_service.dart';

class QuestGeneratorPage extends StatefulWidget {
  const QuestGeneratorPage({super.key});

  @override
  State<QuestGeneratorPage> createState() => _QuestGeneratorPageState();
}

class _QuestGeneratorPageState extends State<QuestGeneratorPage> {
  final _countController = TextEditingController(text: '100');
  bool _saveToDatabase = true;
  bool _addVariance = true;
  bool _returnTemplates = false;
  bool _isGenerating = false;
  String? _resultMessage;
  Map<String, dynamic>? _generationResult;

  final List<String> _allCategories = [
    'General',
    'Strength',
    'Cardio',
    'Flexibility',
    'Endurance',
    'Consistency',
    'WeightLoss',
    'MuscleGain',
  ];

  final List<String> _allDifficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
    'Master',
  ];

  final Set<String> _selectedCategories = {};
  final Set<String> _selectedDifficulties = {};

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _generateQuests() async {
    setState(() {
      _isGenerating = true;
      _resultMessage = null;
      _generationResult = null;
    });

    final count = int.tryParse(_countController.text) ?? 100;

    try {
      final result = await QuestService.generateQuestTemplates(
        count: count,
        saveToDatabase: _saveToDatabase,
        addVariance: _addVariance,
        returnTemplates: _returnTemplates,
        categories:
            _selectedCategories.isEmpty ? null : _selectedCategories.toList(),
        difficulties:
            _selectedDifficulties.isEmpty
                ? null
                : _selectedDifficulties.toList(),
      );

      setState(() {
        _generationResult = result;
        _resultMessage = result['message'] ?? 'Quest templates generated';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_resultMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quests: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Template Generator'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Quest Template Generator',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.blue.shade900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate hundreds of quest templates with proper scaling, difficulty progression, and variety. Use this to populate your quest database.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Count Input
            TextField(
              controller: _countController,
              decoration: const InputDecoration(
                labelText: 'Number of Quests',
                hintText: 'Enter count (1-1000)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Options
            SwitchListTile(
              title: const Text('Save to Database'),
              subtitle: const Text('If disabled, only generates preview'),
              value: _saveToDatabase,
              onChanged: (value) => setState(() => _saveToDatabase = value),
            ),

            SwitchListTile(
              title: const Text('Add Variance'),
              subtitle: const Text('Randomize XP rewards (±10-20)'),
              value: _addVariance,
              onChanged: (value) => setState(() => _addVariance = value),
            ),

            SwitchListTile(
              title: const Text('Return Templates'),
              subtitle: const Text('Show generated templates in response'),
              value: _returnTemplates,
              onChanged: (value) => setState(() => _returnTemplates = value),
            ),

            const SizedBox(height: 24),

            // Category Filter
            Text(
              'Categories (leave empty for all)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _allCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      selectedColor: Colors.blue.shade200,
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Difficulty Filter
            Text(
              'Difficulties (leave empty for all)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _allDifficulties.map((difficulty) {
                    final isSelected = _selectedDifficulties.contains(
                      difficulty,
                    );
                    Color chipColor;
                    switch (difficulty) {
                      case 'Beginner':
                        chipColor = Colors.green.shade200;
                        break;
                      case 'Intermediate':
                        chipColor = Colors.blue.shade200;
                        break;
                      case 'Advanced':
                        chipColor = Colors.orange.shade200;
                        break;
                      case 'Expert':
                        chipColor = Colors.red.shade200;
                        break;
                      case 'Master':
                        chipColor = Colors.purple.shade200;
                        break;
                      default:
                        chipColor = Colors.grey.shade200;
                    }

                    return FilterChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDifficulties.add(difficulty);
                          } else {
                            _selectedDifficulties.remove(difficulty);
                          }
                        });
                      },
                      selectedColor: chipColor,
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQuests,
                icon:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Generate Quest Templates',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_generationResult != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Generation Complete',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.green.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Generated',
                        '${_generationResult!['generated'] ?? 0} templates',
                      ),
                      if (_generationResult!['savedToDb'] != null)
                        _buildResultRow(
                          'Saved',
                          '${_generationResult!['savedToDb']} templates',
                        ),
                      if (_generationResult!['duplicates'] != null)
                        _buildResultRow(
                          'Duplicates Skipped',
                          '${_generationResult!['duplicates']}',
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _resultMessage ?? '',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_resultMessage != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Quick Action Presets
            Text(
              'Quick Presets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildPresetButton(
              'Generate All (200+ templates)',
              Icons.all_inclusive,
              () => _generateAllQuests(),
            ),
            const SizedBox(height: 8),
            _buildPresetButton(
              'Beginner Only (40 templates)',
              Icons.child_friendly,
              () => _generateBeginnerQuests(),
            ),
            const SizedBox(height: 8),
            _buildPresetButton(
              'High Level Only (Expert + Master)',
              Icons.emoji_events,
              () => _generateHighLevelQuests(),
            ),
            const SizedBox(height: 8),
            _buildPresetButton(
              'Strength & Cardio (70 templates)',
              Icons.fitness_center,
              () => _generateStrengthCardioQuests(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPresetButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isGenerating ? null : onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  void _generateAllQuests() {
    setState(() {
      _countController.text = '1000';
      _saveToDatabase = true;
      _addVariance = true;
      _returnTemplates = false;
      _selectedCategories.clear();
      _selectedDifficulties.clear();
    });
    _generateQuests();
  }

  void _generateBeginnerQuests() {
    setState(() {
      _countController.text = '100';
      _saveToDatabase = true;
      _addVariance = true;
      _returnTemplates = false;
      _selectedCategories.clear();
      _selectedDifficulties.clear();
      _selectedDifficulties.add('Beginner');
    });
    _generateQuests();
  }

  void _generateHighLevelQuests() {
    setState(() {
      _countController.text = '200';
      _saveToDatabase = true;
      _addVariance = true;
      _returnTemplates = false;
      _selectedCategories.clear();
      _selectedDifficulties.clear();
      _selectedDifficulties.addAll(['Expert', 'Master']);
    });
    _generateQuests();
  }

  void _generateStrengthCardioQuests() {
    setState(() {
      _countController.text = '100';
      _saveToDatabase = true;
      _addVariance = true;
      _returnTemplates = false;
      _selectedCategories.clear();
      _selectedDifficulties.clear();
      _selectedCategories.addAll(['Strength', 'Cardio']);
    });
    _generateQuests();
  }
}
