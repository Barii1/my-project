import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import 'community_user_profile.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      body: Consumer<SocialProvider>(
        builder: (context, social, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionHeader(title: 'Your Friends', isDark: isDark),
              ...social.friends.map((f) => _FriendTile(name: f, isDark: isDark)),
              const SizedBox(height: 32),
              _SectionHeader(title: 'Requests', isDark: isDark),
              if (social.friendRequests.isEmpty)
                _EmptyCard(isDark: isDark, text: 'No pending requests'),
              ...social.friendRequests.map((r) => _RequestTile(name: r, isDark: isDark)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF34495E),
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final String name;
  final bool isDark;
  const _FriendTile({required this.name, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityUserProfileScreen(username: name, avatar: '👤'),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF3DA89A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String name;
  final bool isDark;
  const _RequestTile({required this.name, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final social = Provider.of<SocialProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
          ),
          TextButton(
            onPressed: () => social.acceptFriend(name),
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () => social.declineFriend(name),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final bool isDark;
  final String text;
  const _EmptyCard({required this.isDark, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
