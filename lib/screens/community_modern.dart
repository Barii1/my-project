import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import 'dart:async';

class CommunityModernScreen extends StatefulWidget {
  const CommunityModernScreen({super.key});

  @override
  State<CommunityModernScreen> createState() => _CommunityModernScreenState();
}

class _CommunityModernScreenState extends State<CommunityModernScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _updateTimer;
  final List<Map<String, dynamic>> _globalUsers = [];
  // Demo-only randomizer removed in non-demo mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeLeaderboard();
    _startPeriodicUpdates();
  }
  
  void _initializeLeaderboard() {
    _globalUsers.addAll([
      {'name': 'Ayesha Khan', 'points': 12450, 'streak': 45},
      {'name': 'Ahmed Ali', 'points': 11890, 'streak': 32},
      {'name': 'Fatima Malik', 'points': 10320, 'streak': 28},
      {'name': 'Hassan Raza', 'points': 9850, 'streak': 25},
      {'name': 'Zainab Ahmed', 'points': 9210, 'streak': 22},
      {'name': 'Usman Sheikh', 'points': 8790, 'streak': 19},
      {'name': 'Maryam Siddiqui', 'points': 8340, 'streak': 17},
      {'name': 'Bilal Hussain', 'points': 7920, 'streak': 15},
      {'name': 'Sana Iqbal', 'points': 7560, 'streak': 12},
      {'name': 'Hamza Farooq', 'points': 7180, 'streak': 10},
      {'name': 'Hira Abbas', 'points': 6850, 'streak': 8},
      {'name': 'Talha Imran', 'points': 6520, 'streak': 7},
    ]);
  }
  
  void _startPeriodicUpdates() {
    // Demo-only updates removed. In non-demo mode, do nothing here.
    _updateTimer?.cancel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final stats = Provider.of<StatsProvider>(context);
    final currentUserName = auth.fullName ?? 'You';
    
    // Add current user to leaderboard dynamically
    final userPoints = stats.totalXp;
    final userStreak = stats.streakDays;
    
    // Create combined list with current user
    final allUsers = List<Map<String, dynamic>>.from(_globalUsers);
    final existingUserIndex = allUsers.indexWhere((u) => u['name'] == currentUserName);
    if (existingUserIndex >= 0) {
      allUsers[existingUserIndex] = {
        'name': currentUserName,
        'points': userPoints,
        'streak': userStreak,
      };
    } else {
      allUsers.add({
        'name': currentUserName,
        'points': userPoints,
        'streak': userStreak,
      });
    }
    allUsers.sort((a, b) => b['points'].compareTo(a['points']));
    final globalUsers = allUsers.map((u) => {
      'name': u['name'],
      'points': _formatPoints(u['points']),
      'streak': u['streak'],
    }).toList();

    final currentUserName2 = currentUserName;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Leaderboard',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF34495E),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('🏆', style: TextStyle(fontSize: 28)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Track your progress and compete with others',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2E45) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: isDark ? Colors.white : const Color(0xFF34495E),
                      unselectedLabelColor: isDark ? Colors.white54 : const Color(0xFF64748B),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.public, size: 18),
                              SizedBox(width: 8),
                              Text('Global'),
                            ],
                          ),
                        ),
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 18),
                              SizedBox(width: 8),
                              Text('Friends'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGlobalLeaderboard(isDark, currentUserName2, globalUsers),
                  _buildFriendsLeaderboard(isDark, currentUserName, stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k';
    }
    return points.toString();
  }
  
  Widget _buildGlobalLeaderboard(bool isDark, String currentUserName, List<Map<String, dynamic>> globalUsers) {
    
    return CustomScrollView(
      slivers: [
        // Top 3 Podium
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd Place
                _buildPodiumCard(
                  rank: 2,
                  name: globalUsers[1]['name'] as String,
                  points: globalUsers[1]['points'] as String,
                  color: const Color(0xFF94A3B8),
                  height: 120,
                  isDark: isDark,
                ),
                const SizedBox(width: 16),
                // 1st Place
                _buildPodiumCard(
                  rank: 1,
                  name: globalUsers[0]['name'] as String,
                  points: globalUsers[0]['points'] as String,
                  color: const Color(0xFFFFD700),
                  height: 150,
                  isDark: isDark,
                  isFirst: true,
                ),
                const SizedBox(width: 16),
                // 3rd Place
                _buildPodiumCard(
                  rank: 3,
                  name: globalUsers[2]['name'] as String,
                  points: globalUsers[2]['points'] as String,
                  color: const Color(0xFFCD7F32),
                  height: 100,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
        // Rest of the list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = globalUsers[index + 3];
                final rank = index + 4;
                final isCurrentUser = user['name'] == currentUserName;
                
                return _buildLeaderboardTile(
                  rank: rank,
                  name: user['name'] as String,
                  points: user['points'] as String,
                  streak: user['streak'] as int,
                  isDark: isDark,
                  isCurrentUser: isCurrentUser,
                );
              },
              childCount: globalUsers.length - 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsLeaderboard(bool isDark, String currentUserName, StatsProvider stats) {
    // Create friends list with numeric points for proper sorting
    final friendsUsersRaw = [
      {'name': currentUserName, 'points': stats.totalXp, 'streak': stats.streakDays},
      {'name': 'Ahmed Ali', 'points': 11890, 'streak': 32},
      {'name': 'Fatima Malik', 'points': 10320, 'streak': 28},
      {'name': 'Hassan Raza', 'points': 9850, 'streak': 25},
      {'name': 'Zainab Ahmed', 'points': 9210, 'streak': 22},
    ];
    
    // Sort by points (highest first)
    friendsUsersRaw.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    
    // Format points for display
    final friendsUsers = friendsUsersRaw.map((u) => {
      'name': u['name'],
      'points': _formatPoints(u['points'] as int),
      'streak': u['streak'],
    }).toList();
    
    if (friendsUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to see their progress',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      itemCount: friendsUsers.length,
      itemBuilder: (context, index) {
        final user = friendsUsers[index];
        final rank = index + 1;
        final isCurrentUser = user['name'] == currentUserName;
        
        return _buildLeaderboardTile(
          rank: rank,
          name: user['name'] as String,
          points: user['points'] as String,
          streak: user['streak'] as int,
          isDark: isDark,
          isCurrentUser: isCurrentUser,
          showMedal: rank <= 3,
        );
      },
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required String name,
    required String points,
    required Color color,
    required double height,
    required bool isDark,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('👑', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: isFirst ? 100 : 85,
          height: isFirst ? 100 : 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                fontSize: isFirst ? 40 : 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 95,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF2A2E45), const Color(0xFF1F2337)]
                : [Colors.white, const Color(0xFFF9FAFB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name.split(' ')[0],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '$points pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile({
    required int rank,
    required String name,
    required String points,
    required int streak,
    required bool isDark,
    bool isCurrentUser = false,
    bool showMedal = false,
  }) {
    String getMedal() {
      if (rank == 1) return '🥇';
      if (rank == 2) return '🥈';
      if (rank == 3) return '🥉';
      return '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark ? const Color(0xFF4DB8A8).withOpacity(0.15) : const Color(0xFF4DB8A8).withOpacity(0.1))
            : (isDark ? const Color(0xFF2A2E45) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF4DB8A8)
              : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser 
              ? const Color(0xFF4DB8A8).withOpacity(0.15)
              : Colors.black.withOpacity(0.04),
            blurRadius: isCurrentUser ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF4DB8A8).withOpacity(0.15),
                          const Color(0xFF4DB8A8).withOpacity(0.05),
                        ],
                      )
                    : null,
                color: rank <= 3 
                    ? null
                    : (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(12),
                border: rank <= 3 
                  ? Border.all(color: const Color(0xFF4DB8A8).withOpacity(0.3), width: 1.5)
                  : null,
              ),
              child: Center(
                child: showMedal && getMedal().isNotEmpty
                    ? Text(getMedal(), style: const TextStyle(fontSize: 22))
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3
                            ? const Color(0xFF4DB8A8)
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DB8A8).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name and streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DB8A8).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFFF8C5A) : const Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1F2937), const Color(0xFF1A1A2E)]
                    : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    points,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF34495E),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'points',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
