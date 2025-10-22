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
  int _totalCount = 0;
  bool _isLoading = true;
  String? _filterCategory;
  String? _filterDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableQuests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableQuests() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final userLevel = userProvider.user?.level ?? 1;

    try {
      final result = await QuestService.browseQuestTemplates(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categories: _filterCategory != null ? [_filterCategory!] : null,
        difficulties: _filterDifficulty != null ? [_filterDifficulty!] : null,
        minLevel: 1,
        maxLevel: userLevel,
        sortBy: 'difficulty',
        ascending: true,
        activeOnly: true,
      );

      setState(() {
        _totalCount = result['totalCount'] as int? ?? 0;
        final templates = result['templates'] as List<dynamic>? ?? [];
        _availableQuests =
            templates.map((q) => QuestTemplate.fromJson(q)).toList();
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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userLevel = userProvider.user?.level ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search quests...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                            _loadAvailableQuests();
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadAvailableQuests();
              },
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Category and Difficulty Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Category Filters
                          _buildFilterChip('All', _filterCategory == null, () {
                            setState(() => _filterCategory = null);
                            _loadAvailableQuests();
                          }, Colors.grey),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'General',
                            _filterCategory == 'General',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'General'
                                            ? null
                                            : 'General',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Strength',
                            _filterCategory == 'Strength',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'Strength'
                                            ? null
                                            : 'Strength',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.red,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Cardio',
                            _filterCategory == 'Cardio',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'Cardio'
                                            ? null
                                            : 'Cardio',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Flexibility',
                            _filterCategory == 'Flexibility',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'Flexibility'
                                            ? null
                                            : 'Flexibility',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Endurance',
                            _filterCategory == 'Endurance',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'Endurance'
                                            ? null
                                            : 'Endurance',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Consistency',
                            _filterCategory == 'Consistency',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'Consistency'
                                            ? null
                                            : 'Consistency',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Weight Loss',
                            _filterCategory == 'WeightLoss',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'WeightLoss'
                                            ? null
                                            : 'WeightLoss',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.pink,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Muscle Gain',
                            _filterCategory == 'MuscleGain',
                            () {
                              setState(
                                () =>
                                    _filterCategory =
                                        _filterCategory == 'MuscleGain'
                                            ? null
                                            : 'MuscleGain',
                              );
                              _loadAvailableQuests();
                            },
                            Colors.deepOrange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Difficulty Filters
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text(
                            'Difficulty: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'All',
                            _filterDifficulty == null,
                            () {
                              setState(() => _filterDifficulty = null);
                              _loadAvailableQuests();
                            },
                            Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Beginner',
                            _filterDifficulty == 'Beginner',
                            () {
                              setState(
                                () =>
                                    _filterDifficulty =
                                        _filterDifficulty == 'Beginner'
                                            ? null
                                            : 'Beginner',
                              );
                              _loadAvailableQuests();
                            },
                            const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Intermediate',
                            _filterDifficulty == 'Intermediate',
                            () {
                              setState(
                                () =>
                                    _filterDifficulty =
                                        _filterDifficulty == 'Intermediate'
                                            ? null
                                            : 'Intermediate',
                              );
                              _loadAvailableQuests();
                            },
                            const Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Advanced',
                            _filterDifficulty == 'Advanced',
                            () {
                              setState(
                                () =>
                                    _filterDifficulty =
                                        _filterDifficulty == 'Advanced'
                                            ? null
                                            : 'Advanced',
                              );
                              _loadAvailableQuests();
                            },
                            const Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Expert',
                            _filterDifficulty == 'Expert',
                            () {
                              setState(
                                () =>
                                    _filterDifficulty =
                                        _filterDifficulty == 'Expert'
                                            ? null
                                            : 'Expert',
                              );
                              _loadAvailableQuests();
                            },
                            const Color(0xFFE91E63),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Master',
                            _filterDifficulty == 'Master',
                            () {
                              setState(
                                () =>
                                    _filterDifficulty =
                                        _filterDifficulty == 'Master'
                                            ? null
                                            : 'Master',
                              );
                              _loadAvailableQuests();
                            },
                            const Color(0xFF9C27B0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Total Count
                  if (_totalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Showing ${_availableQuests.length} of $_totalCount quest${_totalCount != 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                  // Quest List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadAvailableQuests,
                      child:
                          _availableQuests.isEmpty
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
                                      _searchQuery.isNotEmpty
                                          ? 'No quests match your search'
                                          : _filterCategory != null ||
                                              _filterDifficulty != null
                                          ? 'No quests match your filters'
                                          : 'No quests available for your level',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Level: $userLevel',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (_searchQuery.isNotEmpty ||
                                        _filterCategory != null ||
                                        _filterDifficulty != null) ...[
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                            _filterCategory = null;
                                            _filterDifficulty = null;
                                          });
                                          _loadAvailableQuests();
                                        },
                                        icon: const Icon(Icons.clear_all),
                                        label: const Text('Clear Filters'),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _availableQuests.length,
                                itemBuilder: (context, index) {
                                  final quest = _availableQuests[index];
                                  return _buildQuestCard(quest, userLevel);
                                },
                              ),
                    ),
                  ),
                ],
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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade800,
      selectedColor: color,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
