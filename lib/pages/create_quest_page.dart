import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/quest_service.dart';

class CreateQuestPage extends StatefulWidget {
  final int? questId;
  final Map<String, dynamic>? initialData;

  const CreateQuestPage({super.key, this.questId, this.initialData});

  @override
  State<CreateQuestPage> createState() => _CreateQuestPageState();
}

class _CreateQuestPageState extends State<CreateQuestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _xpRewardController = TextEditingController();

  String _priority = 'Medium';
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      _xpRewardController.text =
          widget.initialData!['xpReward']?.toString() ?? '50';
      _priority = widget.initialData!['priority'] ?? 'Medium';
      if (widget.initialData!['dueDate'] != null) {
        _dueDate = DateTime.tryParse(widget.initialData!['dueDate']);
      }
    } else {
      _xpRewardController.text = '50';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveQuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      }
      setState(() => _isSaving = false);
      return;
    }

    try {
      final userIdInt = int.parse(userId);
      if (widget.questId != null) {
        // Update existing quest
        await QuestService.updateQuest(
          userId: userIdInt,
          questId: widget.questId!,
          title: _titleController.text,
          description: _descriptionController.text,
          xpReward: int.tryParse(_xpRewardController.text),
          priority: _priority,
          dueDate: _dueDate?.toIso8601String(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quest updated successfully!')),
          );
        }
      } else {
        // Create new quest
        print(
          'CreateQuestPage: Creating quest with dueDate: ${_dueDate?.toIso8601String()}',
        );
        await QuestService.createQuest(
          userId: userIdInt,
          title: _titleController.text,
          description: _descriptionController.text,
          xpReward: int.tryParse(_xpRewardController.text) ?? 50,
          priority: _priority,
          dueDate: _dueDate?.toIso8601String(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quest created successfully!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving quest: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.questId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Quest' : 'Create Quest'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveQuest,
              child: const Text(
                'SAVE',
                style: TextStyle(color: Color(0xFF00FF99)),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter quest title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter quest description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items:
                  ['Low', 'Medium', 'High', 'Critical'].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _xpRewardController,
              decoration: const InputDecoration(
                labelText: 'XP Reward',
                hintText: 'Enter XP reward',
                border: OutlineInputBorder(),
                suffixText: 'XP',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter XP reward';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date (Optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _dueDate == null
                      ? 'Select due date'
                      : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: TextStyle(
                    color: _dueDate == null ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade900.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Choose a clear, motivating title\n'
                      '• Set realistic XP rewards based on difficulty\n'
                      '• Use priority to organize your quests\n'
                      '• Add exercises after creating the quest',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
