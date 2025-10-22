import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest_template.dart';
import '../providers/user_provider.dart';
import '../services/quest_service.dart';

class AvailableQuestsPage extends StatefulWidget {
  const AvailableQuestsPage({super.key});

  @override
  State<AvailableQuestsPage> createState() => _AvailableQuestsPageState();
}

class _AvailableQuestsPageState extends State<AvailableQuestsPage> {
  List<QuestTemplate> _availableQuests = [];
  bool _isLoading = true;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _loadAvailableQuests();
  }

  Future<void> _loadAvailableQuests() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await QuestService.getAvailableQuests(userId);
      setState(() {
        _availableQuests = data.map((q) => QuestTemplate.fromJson(q)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading available quests: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error loading quests: $e')));
          }
        });
      }
    }
  }

  Future<void> _claimQuest(QuestTemplate template) async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) return;

    try {
      await QuestService.claimQuest(userId: userId, templateId: template.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quest "${template.title}" claimed!')),
        );
        Navigator.pop(context, true); // Return true to refresh quests list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to claim quest: $e')));
      }
    }
  }

  List<QuestTemplate> get _filteredQuests {
    if (_filterCategory == null) return _availableQuests;
    return _availableQuests
        .where((q) => q.category == _filterCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userLevel = userProvider.user?.level ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quests'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterCategory = value == 'All' ? null : value;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'All',
                    child: Text('All Categories'),
                  ),
                  const PopupMenuItem(value: 'General', child: Text('General')),
                  const PopupMenuItem(
                    value: 'Strength',
                    child: Text('Strength'),
                  ),
                  const PopupMenuItem(value: 'Cardio', child: Text('Cardio')),
                  const PopupMenuItem(
                    value: 'Flexibility',
                    child: Text('Flexibility'),
                  ),
                  const PopupMenuItem(
                    value: 'Endurance',
                    child: Text('Endurance'),
                  ),
                  const PopupMenuItem(
                    value: 'WeightLoss',
                    child: Text('Weight Loss'),
                  ),
                  const PopupMenuItem(
                    value: 'MuscleGain',
                    child: Text('Muscle Gain'),
                  ),
                  const PopupMenuItem(
                    value: 'Consistency',
                    child: Text('Consistency'),
                  ),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadAvailableQuests,
                child:
                    _filteredQuests.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filterCategory == null
                                    ? 'No quests available for your level'
                                    : 'No $_filterCategory quests available',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Level: $userLevel',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredQuests.length,
                          itemBuilder: (context, index) {
                            final quest = _filteredQuests[index];
                            return _buildQuestCard(quest, userLevel);
                          },
                        ),
              ),
    );
  }

  Widget _buildQuestCard(QuestTemplate quest, int userLevel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: quest.getDifficultyColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showQuestDetails(quest),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      quest.difficulty,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: quest.getDifficultyColor(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quest.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.category, quest.category, Colors.blue),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.timer,
                    '${quest.durationDays} days',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.star,
                    '${quest.xpReward} XP',
                    Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Level ${quest.minLevel}-${quest.maxLevel}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestDetails(QuestTemplate quest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quest.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              quest.difficulty,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: quest.getDifficultyColor(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        quest.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Quest Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Category', quest.category),
                      _buildDetailRow('Duration', '${quest.durationDays} days'),
                      _buildDetailRow('XP Reward', '${quest.xpReward} XP'),
                      _buildDetailRow(
                        'Level Range',
                        '${quest.minLevel}-${quest.maxLevel}',
                      ),
                      if (quest.targetMetrics != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Target Metrics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...quest.targetMetrics!.entries.map(
                          (entry) => _buildDetailRow(
                            entry.key,
                            entry.value.toString(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _claimQuest(quest);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Claim Quest',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
