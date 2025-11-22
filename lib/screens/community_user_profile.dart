import 'package:flutter/material.dart';

class CommunityUserProfileScreen extends StatelessWidget {
  final String username;
  final String avatar;
  final String bio;
  
  const CommunityUserProfileScreen({
    super.key,
    required this.username,
    this.avatar = '👤',
    this.bio = 'Passionate learner exploring new topics!',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        shadowColor: isDark ? Colors.black26 : const Color(0xFFFFE6ED),
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DB8A8).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('42', 'Posts', isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('128', 'Likes', isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('3', 'Groups', isDark),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: isDark ? const Color(0xFF4DB8A8) : const Color(0xFF3DA89A),
                    unselectedLabelColor: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    indicatorColor: const Color(0xFF4DB8A8),
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Questions'),
                      Tab(text: 'Groups'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildPostsList(isDark),
                        _buildQuestionsList(isDark),
                        _buildGroupsList(isDark),
                      ],
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

  Widget _buildStatCard(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(bool isDark) {
    return ListView(
      children: [
        _buildPostItem(
          'Just completed the Algorithms course! 🎉',
          '2 days ago',
          '24 likes',
          isDark,
        ),
        const SizedBox(height: 12),
        _buildPostItem(
          'Sharing my notes on Dynamic Programming',
          '1 week ago',
          '56 likes',
          isDark,
        ),
      ],
    );
  }

  Widget _buildQuestionsList(bool isDark) {
    return ListView(
      children: [
        _buildQuestionItem(
          'How to optimize recursive solutions?',
          '3 answers',
          isDark,
        ),
        const SizedBox(height: 12),
        _buildQuestionItem(
          'Best resources for learning Data Structures?',
          '7 answers',
          isDark,
        ),
      ],
    );
  }

  Widget _buildGroupsList(bool isDark) {
    return ListView(
      children: [
        _buildGroupItem('Physics Study Circle', '24 members', isDark),
        const SizedBox(height: 12),
        _buildGroupItem('Calculus Masters', '18 members', isDark),
        const SizedBox(height: 12),
        _buildGroupItem('Chemistry Lab Partners', '32 members', isDark),
      ],
    );
  }

  Widget _buildPostItem(String content, String time, String likes, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.favorite_outline,
                size: 14,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                likes,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String question, String answers, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                answers,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(String name, String members, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
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
                Text(
                  members,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}
