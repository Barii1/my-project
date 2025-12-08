import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../providers/auth_provider.dart' as MyAuth;
import '../../../services/friend_service.dart';
import '../../friends_screen.dart';
import '../../add_friend_screen.dart';
import '../../friend_chat_screen.dart';

class FriendsSection extends StatefulWidget {
  const FriendsSection({super.key});

  @override
  State<FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<FriendsSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfNewUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkIfNewUser() async {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);
    final currentUserName = authProvider.fullName ?? 'User';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final friendService = FriendService();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF2A2E45)) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0,2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen())),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Friend>>(
                  stream: friendService.getFriendsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildNoFriendsView(isDark);
                    }
                    return _buildFriendsListView(isDark, currentUserName, currentUserId ?? '', snapshot.data!);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildNoFriendsView(bool isDark) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 32,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No friends yet',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsListView(
    bool isDark,
    String currentUserName,
    String currentUserId,
    List<Friend> friends,
  ) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == friends.length) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFriendScreen())),
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                ),
                child: const Center(child: Icon(Icons.person_add_alt_1, color: Color(0xFF3DA89A))),
              ),
            );
          }
          final friend = friends[index];
          final firstName = friend.friendName.split(' ').first;
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendChatScreen(
                    friendId: friend.userId,
                    friendName: friend.friendName,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName,
                  ),
                ),
              );
            },
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  firstName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
