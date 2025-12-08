import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../providers/stats_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/friend_service.dart';
import 'add_friend_screen.dart';
import 'friend_chat_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k';
    }
    return points.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final stats = Provider.of<StatsProvider>(context);
    final currentUserName = auth.fullName ?? 'You';
    final currentUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
    final friendService = FriendService();
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFriendScreen()),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Friend Requests Section
          StreamBuilder<List<FriendRequest>>(
            stream: friendService.getPendingRequestsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final requests = snapshot.data!;
              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_add, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Friend Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...requests.map((request) => _RequestTile(
                        request: request,
                        isDark: isDark,
                        friendService: friendService,
                      )),
                ]),
              );
            },
          ),

          // Friends List Section
          StreamBuilder<List<Friend>>(
            stream: friendService.getFriendsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4DB8A8)),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
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
                          'Search for users and add friends',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                          ),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add Friends'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB8A8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return FutureBuilder<List<LeaderboardEntry>>(
                future: friendService.getFriendsLeaderboard(),
                builder: (context, leaderboardSnapshot) {
                  if (leaderboardSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: Color(0xFF4DB8A8)),
                        ),
                      ),
                    );
                  }
                  
                  final leaderboardEntries = leaderboardSnapshot.data ?? [];
                  
                  // Add current user to leaderboard
                  final allEntries = [
                    LeaderboardEntry(
                      userId: currentUserId,
                      displayName: currentUserName,
                      username: '',
                      xp: stats.totalXp,
                      streakDays: stats.streakDays,
                    ),
                    ...leaderboardEntries,
                  ];
                  
                  // Sort by XP desc
                  allEntries.sort((a, b) => b.xp.compareTo(a.xp));

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Text(
                          'Friends Leaderboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                          ),
                        ),
                      ),
                      ...allEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final user = entry.value;
                        final rank = index + 1;
                        final isCurrentUser = user.userId == currentUserId;
                        final name = user.displayName;
                        final userId = isCurrentUser ? null : user.userId;
                        final points = _formatPoints(user.xp);
                        final streak = user.streakDays;

                        return _buildLeaderboardTile(
                          context: context,
                          rank: rank,
                          name: name,
                          points: points,
                          streak: streak,
                          isDark: isDark,
                          isCurrentUser: isCurrentUser,
                          showMedal: rank <= 3,
                          currentUserName: currentUserName,
                          currentUserId: currentUserId,
                          friendUserId: userId,
                        );
                      }),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile({
    required BuildContext context,
    required int rank,
    required String name,
    required String points,
    required int streak,
    required bool isDark,
    required bool isCurrentUser,
    required String currentUserName,
    required String currentUserId,
    String? friendUserId,
    bool showMedal = false,
  }) {
    Color getMedalColor() {
      if (rank == 1) return const Color(0xFFFFD700);
      if (rank == 2) return const Color(0xFF94A3B8);
      if (rank == 3) return const Color(0xFFCD7F32);
      return Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF16213E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF4DB8A8)
              : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: showMedal
                  ? getMedalColor()
                  : (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                showMedal ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                style: TextStyle(
                  fontSize: showMedal ? 20 : 14,
                  fontWeight: FontWeight.bold,
                  color: showMedal
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF34495E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB8A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$points XP',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DB8A8),
              ),
            ),
          ),
          if (!isCurrentUser) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (friendUserId == null || friendUserId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to open chat for this user')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendChatScreen(
                      friendId: friendUserId,
                      friendName: name,
                      currentUserId: currentUserId,
                      currentUserName: currentUserName,
                    ),
                  ),
                );
              },
              color: const Color(0xFF4DB8A8),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  final FriendRequest request;
  final bool isDark;
  final FriendService friendService;
  
  const _RequestTile({
    required this.request,
    required this.isDark,
    required this.friendService,
  });

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _isProcessing = false;

  Future<void> _acceptRequest() async {
    setState(() => _isProcessing = true);
    
    final success = await widget.friendService.acceptFriendRequest(
      fromUserId: widget.request.fromUserId,
      fromUserName: widget.request.fromUserName,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${widget.request.fromUserName}!'),
          backgroundColor: const Color(0xFF4DB8A8),
        ),
      );
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest() async {
    setState(() => _isProcessing = true);
    
    final success = await widget.friendService.rejectFriendRequest(
      widget.request.fromUserId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: Color(0xFF94A3B8),
        ),
      );
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.request.fromUserName.isNotEmpty
                    ? widget.request.fromUserName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.request.fromUserName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
          ),
          if (_isProcessing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4DB8A8),
              ),
            )
          else ...[
            TextButton(
              onPressed: _acceptRequest,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4DB8A8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: _rejectRequest,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Decline'),
            ),
          ],
        ],
      ),
    );
  }
}
