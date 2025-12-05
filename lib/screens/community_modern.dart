import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/friend_service.dart';
import 'dart:async';

class CommunityModernScreen extends StatefulWidget {
  const CommunityModernScreen({super.key});

  @override
  State<CommunityModernScreen> createState() => _CommunityModernScreenState();
}

class _CommunityModernScreenState extends State<CommunityModernScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _updateTimer;
  final _searchController = TextEditingController();
  // Demo-only randomizer removed in non-demo mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startPeriodicUpdates();
  }
  
  void _initializeLeaderboard() {}
  
  void _startPeriodicUpdates() {
    // Demo-only updates removed. In non-demo mode, do nothing here.
    _updateTimer?.cancel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _updateTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final currentUserName = auth.fullName ?? (auth.email ?? 'You');

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
                  _buildGlobalLeaderboard(isDark, currentUserName),
                  _buildFriendsLeaderboard(isDark, currentUserName),
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
  
  Widget _buildGlobalLeaderboard(bool isDark, String currentUserName) {
    final service = FriendService();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FutureBuilder<List<LeaderboardEntry>>(
            future: service.getGlobalLeaderboard(limit: 15),
            builder: (context, snapshot) {
              final entries = snapshot.data ?? [];
              if (entries.length < 3) {
                return const SizedBox.shrink();
              }
              final top3 = entries.take(3).toList();
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildPodiumCard(
                      rank: 2,
                      name: top3[1].displayName,
                      points: _formatPoints(top3[1].xp),
                      color: const Color(0xFF94A3B8),
                      height: 120,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _buildPodiumCard(
                      rank: 1,
                      name: top3[0].displayName,
                      points: _formatPoints(top3[0].xp),
                      color: const Color(0xFFFFD700),
                      height: 150,
                      isDark: isDark,
                      isFirst: true,
                    ),
                    const SizedBox(width: 16),
                    _buildPodiumCard(
                      rank: 3,
                      name: top3[2].displayName,
                      points: _formatPoints(top3[2].xp),
                      color: const Color(0xFFCD7F32),
                      height: 100,
                      isDark: isDark,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Top 3 Podium
        // Rest of the list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FutureBuilder<List<LeaderboardEntry>>(
                  future: service.getGlobalLeaderboard(limit: 15),
                  builder: (context, snapshot) {
                    final entries = snapshot.data ?? [];
                    if (entries.length <= 3) return const SizedBox.shrink();
                    final entry = entries[index + 3];
                    final rank = index + 4;
                    final isCurrentUser = entry.displayName == currentUserName;
                    return _buildLeaderboardTile(
                      rank: rank,
                      name: entry.displayName,
                      points: _formatPoints(entry.xp),
                      streak: entry.streakDays,
                      isDark: isDark,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                );
              },
              childCount: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsLeaderboard(bool isDark, String currentUserName) {
    final service = FriendService();
    
    // Search + Add friend UI
    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final q = _searchController.text.trim();
              if (q.isEmpty) return;
              final results = await service.searchUsersByUsernamePrefix(q);
              if (!mounted) return;
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return ListView(
                    children: results.map((r) {
                      return FutureBuilder<bool>(
                        future: service.isFriend(r.userId),
                        builder: (context, snapFriend) {
                          return FutureBuilder<String?>(
                            future: service.getRequestStatus(r.userId),
                            builder: (context, snapReq) {
                              final isFriend = snapFriend.data == true;
                              final reqStatus = snapReq.data; // 'pending' / 'accepted' / 'rejected' / null
                              String trailingLabel;
                              VoidCallback? trailingAction;
                              if (isFriend) {
                                trailingLabel = 'Friends';
                              } else if (reqStatus == 'pending') {
                                trailingLabel = 'Pending';
                              } else {
                                trailingLabel = 'Add Friend';
                                trailingAction = () async {
                                  final ok = await service.sendFriendRequest(
                                    toUserId: r.userId,
                                    toUserName: r.fullName.isNotEmpty ? r.fullName : r.email,
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ok ? 'Request sent' : 'Could not send request')),
                                  );
                                };
                              }

                              return ListTile(
                        leading: const Icon(Icons.person_add_alt_1),
                        title: Text(r.fullName.isNotEmpty ? r.fullName : r.email),
                        subtitle: Text(r.email),
                                trailing: TextButton(
                                  onPressed: trailingAction,
                                  child: Text(trailingLabel),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );

    // Friends leaderboard + pending requests list
    return FutureBuilder<List<LeaderboardEntry>>(
      future: service.getFriendsLeaderboard(limit: 15),
      builder: (context, snapshot) {
        final friendsEntries = snapshot.data ?? [];
        if (friendsEntries.isEmpty) {
          return Column(
            children: [
              searchBar,
              // Pending requests section (even if no friends yet)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: StreamBuilder<List<FriendRequest>>(
                  stream: service.getPendingRequestsStream(),
                  builder: (context, reqSnap) {
                    final pending = reqSnap.data ?? [];
                    if (pending.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pending Requests', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...pending.map((req) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: Text(req.fromUserName.isNotEmpty ? req.fromUserName : req.fromUserId),
                            subtitle: Text('Received ${req.receivedAt.toLocal()}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final ok = await service.acceptFriendRequest(
                                      fromUserId: req.fromUserId,
                                      fromUserName: req.fromUserName,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Accepted' : 'Failed to accept')),
                                    );
                                  },
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await service.rejectFriendRequest(req.fromUserId);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Declined' : 'Failed to decline')),
                                    );
                                  },
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Center(
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
                ),
              ),
            ],
          );
        }
        // Build list with a header section for pending requests
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          itemCount: friendsEntries.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return searchBar;
            // Insert pending requests block after search
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StreamBuilder<List<FriendRequest>>(
                  stream: service.getPendingRequestsStream(),
                  builder: (context, reqSnap) {
                    final pending = reqSnap.data ?? [];
                    if (pending.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pending Requests', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...pending.map((req) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: Text(req.fromUserName.isNotEmpty ? req.fromUserName : req.fromUserId),
                            subtitle: Text('Received ${req.receivedAt.toLocal()}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final ok = await service.acceptFriendRequest(
                                      fromUserId: req.fromUserId,
                                      fromUserName: req.fromUserName,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Accepted' : 'Failed to accept')),
                                    );
                                  },
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await service.rejectFriendRequest(req.fromUserId);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Declined' : 'Failed to decline')),
                                    );
                                  },
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              );
            }
            // Sent requests section
            if (index == 2) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StreamBuilder<List<OutgoingFriendRequest>>(
                  stream: service.getSentRequestsStream(),
                  builder: (context, sentSnap) {
                    final sent = sentSnap.data ?? [];
                    if (sent.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sent Requests', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...sent.map((req) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.outgoing_mail),
                            title: Text(req.toUserName.isNotEmpty ? req.toUserName : req.toUserId),
                            subtitle: Text('Sent ${req.sentAt.toLocal()}'),
                            trailing: TextButton(
                              onPressed: () async {
                                final ok = await service.cancelSentRequest(req.toUserId);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(ok ? 'Request canceled' : 'Failed to cancel request')),
                                );
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              );
            }
            final entry = friendsEntries[index - 1];
            final rank = index; // ranks account for the search bar at index 0
            final isCurrentUser = entry.displayName == currentUserName;
            return _buildLeaderboardTile(
              rank: rank,
              name: entry.displayName,
              points: _formatPoints(entry.xp),
              streak: entry.streakDays,
              isDark: isDark,
              isCurrentUser: isCurrentUser,
              showMedal: rank <= 3,
            );
          },
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
