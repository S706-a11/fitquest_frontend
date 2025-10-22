import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/quest_service.dart';
import '../models/quest.dart';
import 'quest_detail_page.dart';
import 'available_quests_page.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Quest> _activeQuests = [];
  List<Quest> _completedQuests = [];
  bool _isLoading = true;
  String _sortBy = 'priority'; // priority, dueDate, progress

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final activeQuestsData = await QuestService.getActiveQuests(userId);
      final completedQuestsData = await QuestService.getCompletedQuests(userId);

      setState(() {
        _activeQuests = activeQuestsData.map((q) => Quest.fromJson(q)).toList();
        _completedQuests =
            completedQuestsData.map((q) => Quest.fromJson(q)).toList();
        _sortQuests();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Use addPostFrameCallback to show SnackBar after build is complete
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

  void _sortQuests() {
    switch (_sortBy) {
      case 'priority':
        final priorityOrder = {'Critical': 0, 'High': 1, 'Medium': 2, 'Low': 3};
        _activeQuests.sort(
          (a, b) => (priorityOrder[a.priority] ?? 4).compareTo(
            priorityOrder[b.priority] ?? 4,
          ),
        );
        _completedQuests.sort(
          (a, b) => (priorityOrder[a.priority] ?? 4).compareTo(
            priorityOrder[b.priority] ?? 4,
          ),
        );
        break;
      case 'dueDate':
        _activeQuests.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        _completedQuests.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'progress':
        _activeQuests.sort(
          (a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0),
        );
        _completedQuests.sort(
          (a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text(
          'QUESTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortQuests();
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'priority',
                    child: Text('Sort by Priority'),
                  ),
                  const PopupMenuItem(
                    value: 'dueDate',
                    child: Text('Sort by Due Date'),
                  ),
                  const PopupMenuItem(
                    value: 'progress',
                    child: Text('Sort by Progress'),
                  ),
                ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadQuests),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Completed')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildQuestList(_activeQuests, isActive: true),
                  _buildQuestList(_completedQuests, isActive: false),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AvailableQuestsPage()),
          );
          if (result == true) {
            _loadQuests();
          }
        },
        backgroundColor: const Color(0xFF00FF99),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildQuestList(List<Quest> quests, {required bool isActive}) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.flag_outlined : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active quests' : 'No completed quests',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap + to browse available quests',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: quests.length,
        itemBuilder: (_, i) {
          final quest = quests[i];
          return _QuestListItem(
            quest: quest,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestDetailPage(questId: quest.id),
                ),
              );
              if (result == true) {
                _loadQuests();
              }
            },
          );
        },
      ),
    );
  }
}

class _QuestListItem extends StatelessWidget {
  final Quest quest;
  final VoidCallback onTap;

  const _QuestListItem({required this.quest, required this.onTap});

  Color _getPriorityColor() {
    switch (quest.priority) {
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

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return 'No progress';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quest.priority,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quest.description,
                style: const TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(quest.duration),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.fitness_center, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.totalReps ?? 0} reps',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.scale, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.totalWeight?.toStringAsFixed(1) ?? '0'} kg',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              if (quest.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${quest.dueDate}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF99),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${quest.xpReward} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    quest.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color:
                        quest.isCompleted
                            ? const Color(0xFF00FF99)
                            : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
