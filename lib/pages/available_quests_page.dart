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

    try {
      // Load ALL quests, not filtered by user level
      final result = await QuestService.browseQuestTemplates(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categories: _filterCategory != null ? [_filterCategory!] : null,
        difficulties: _filterDifficulty != null ? [_filterDifficulty!] : null,
        minLevel: null, // Remove level filtering
        maxLevel: null, // Remove level filtering
        sortBy: 'minLevel', // Sort by level requirement
        ascending: true,
        activeOnly: true,
      );

      setState(() {
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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.view_list_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'QUEST BOARD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a237e),
                const Color(0xFF0d47a1),
                const Color(0xFF01579b),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search quests...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.cyan[300]),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.red[300]),
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
                  fillColor: const Color(0xFF1a1f3a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.cyan, width: 2),
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
                  // Player Stats Banner
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1a237e).withOpacity(0.8),
                          const Color(0xFF0d47a1).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade700,
                                Colors.amber.shade400,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ADVENTURER LEVEL',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'LVL $userLevel',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_availableQuests.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'QUESTS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.grey.shade800.withOpacity(
                                              0.3,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off,
                                        size: 80,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'NO QUESTS FOUND'
                                          : _filterCategory != null ||
                                              _filterDifficulty != null
                                          ? 'NO MATCHING QUESTS'
                                          : 'NO QUESTS AVAILABLE',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400,
                                        letterSpacing: 2,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.cyan.shade700,
                                            Colors.cyan.shade900,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.cyan.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.shield,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'LEVEL $userLevel',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_searchQuery.isNotEmpty ||
                                        _filterCategory != null ||
                                        _filterDifficulty != null) ...[
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red.shade700,
                                              Colors.red.shade900,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.shade400,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchQuery = '';
                                              _filterCategory = null;
                                              _filterDifficulty = null;
                                            });
                                            _loadAvailableQuests();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.restart_alt,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'RESET FILTERS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
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
    final isLocked = userLevel < quest.minLevel;
    final isOutleveled = userLevel > quest.maxLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isLocked
                    ? Colors.black38
                    : quest.getDifficultyColor().withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isLocked
                        ? [
                          const Color(0xFF1a1f3a).withOpacity(0.4),
                          const Color(0xFF0d1123).withOpacity(0.4),
                        ]
                        : [const Color(0xFF1a1f3a), const Color(0xFF0d1123)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isLocked
                        ? Colors.grey.withOpacity(0.2)
                        : quest.getDifficultyColor().withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          // Diagonal stripe pattern for locked quests
          if (isLocked)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(painter: _DiagonalStripesPainter()),
              ),
            ),
          // Content
          Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showQuestDetails(quest, userLevel),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLocked)
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade700,
                                    Colors.red.shade900,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock,
                                size: 24,
                                color: Colors.white,
                              ),
                            )
                          else
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    quest.getDifficultyColor(),
                                    quest.getDifficultyColor().withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: quest.getDifficultyColor().withOpacity(
                                    0.5,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: quest
                                        .getDifficultyColor()
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.stars,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quest.title.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isLocked
                                            ? Colors.grey[500]
                                            : Colors.white,
                                    letterSpacing: 1,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  quest.difficulty.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isLocked
                                            ? Colors.grey[600]
                                            : quest.getDifficultyColor(),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          quest.description,
                          style: TextStyle(
                            color:
                                isLocked ? Colors.grey[600] : Colors.grey[300],
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildGameInfoChip(
                            Icons.category_outlined,
                            quest.category,
                            Colors.cyan,
                            isLocked,
                          ),
                          _buildGameInfoChip(
                            Icons.access_time,
                            '${quest.durationDays}D',
                            Colors.purple,
                            isLocked,
                          ),
                          _buildGameInfoChip(
                            Icons.auto_awesome,
                            '${quest.xpReward} XP',
                            Colors.amber,
                            isLocked,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: isLocked ? Colors.grey : Colors.cyan,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'LVL ${quest.minLevel}-${quest.maxLevel}',
                                  style: TextStyle(
                                    color:
                                        isLocked
                                            ? Colors.grey[600]
                                            : Colors.cyan[300],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade700,
                                      Colors.red.shade900,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.shade400,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LVL ${quest.minLevel}+',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (isOutleveled)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade600,
                                      Colors.orange.shade800,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'TOO EASY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade600,
                                      Colors.green.shade800,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.green.shade400,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'AVAILABLE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoChip(
    IconData icon,
    String label,
    Color color,
    bool isLocked,
  ) {
    final chipColor = isLocked ? Colors.grey.shade700 : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withOpacity(isLocked ? 0.2 : 0.3),
            chipColor.withOpacity(isLocked ? 0.1 : 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withOpacity(isLocked ? 0.3 : 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
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

  void _showQuestDetails(QuestTemplate quest, int userLevel) {
    final isLocked = userLevel < quest.minLevel;
    final isOutleveled = userLevel > quest.maxLevel;
    final canClaim = !isLocked && !isOutleveled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1a237e).withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color:
                    isLocked
                        ? Colors.red.withOpacity(0.5)
                        : quest.getDifficultyColor().withOpacity(0.5),
                width: 3,
              ),
            ),
            child: DraggableScrollableSheet(
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
                        // Header with lock indicator
                        if (isLocked)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade900.withOpacity(0.4),
                                  Colors.red.shade700.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'QUEST LOCKED',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reach Level ${quest.minLevel} to unlock',
                                        style: TextStyle(
                                          color: Colors.red[200],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Title Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                quest.getDifficultyColor().withOpacity(0.3),
                                quest.getDifficultyColor().withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: quest.getDifficultyColor().withOpacity(
                                0.5,
                              ),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      quest.getDifficultyColor(),
                                      quest.getDifficultyColor().withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: quest
                                          .getDifficultyColor()
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isLocked ? Icons.lock : Icons.emoji_events,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quest.difficulty.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: quest.getDifficultyColor(),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quest.title.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Description Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.cyan.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            quest.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[300],
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Quest Details Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade700,
                                    Colors.amber.shade500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'QUEST DETAILS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Category', quest.category),
                              _buildDetailRow(
                                'Duration',
                                '${quest.durationDays} days',
                              ),
                              _buildDetailRow(
                                'XP Reward',
                                '${quest.xpReward} XP',
                              ),
                              _buildDetailRow(
                                'Level Range',
                                '${quest.minLevel}-${quest.maxLevel}',
                              ),
                              _buildDetailRow('Your Level', '$userLevel'),
                            ],
                          ),
                        ),
                        if (quest.targetMetrics != null) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.shade700,
                                      Colors.purple.shade500,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.track_changes,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'TARGET METRICS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.2),
                                  Colors.purple.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children:
                                  quest.targetMetrics!.entries
                                      .map(
                                        (entry) => _buildDetailRow(
                                          entry.key,
                                          entry.value.toString(),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        // Claim Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                canClaim
                                    ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.4),
                                        blurRadius: 16,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                    : null,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  canClaim
                                      ? () {
                                        Navigator.pop(context);
                                        _claimQuest(quest);
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    canClaim
                                        ? null
                                        : (isLocked
                                            ? Colors.red.shade900
                                            : Colors.orange.shade900),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ).copyWith(
                                backgroundColor:
                                    canClaim
                                        ? WidgetStateProperty.all(
                                          Colors.transparent,
                                        )
                                        : null,
                                shadowColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Container(
                                decoration:
                                    canClaim
                                        ? BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade600,
                                              Colors.green.shade800,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        )
                                        : null,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isLocked
                                          ? Icons.lock
                                          : isOutleveled
                                          ? Icons.warning_amber
                                          : Icons.emoji_events,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isLocked
                                          ? 'LOCKED - LEVEL ${quest.minLevel} REQUIRED'
                                          : isOutleveled
                                          ? 'TOO EASY FOR YOUR LEVEL'
                                          : 'CLAIM QUEST',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!canClaim)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                isLocked
                                    ? 'Keep leveling up to unlock this quest!'
                                    : 'This quest is designed for lower level players.',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for diagonal stripes on locked quests
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
