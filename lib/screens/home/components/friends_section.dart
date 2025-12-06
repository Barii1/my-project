import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/auth_provider.dart' as MyAuth;
import '../../friends_screen.dart';
import '../../add_friend_screen.dart';
import '../../demo_friend_profile_screen.dart';

class FriendsSection extends StatefulWidget {
  const FriendsSection({super.key});

  @override
  State<FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<FriendsSection> {
  bool _isNewUser = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfNewUser();
  }

  Future<void> _checkIfNewUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final data = doc.data();
      // User is "new" if they have 0 XP or no lastActiveDate
      final xp = (data?['xp'] as int?) ?? 0;
      final hasBeenActive = data?['lastActiveDate'] != null;
      
      setState(() {
        _isNewUser = xp == 0 && !hasBeenActive;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);
    final currentUserName = authProvider.fullName ?? 'User';
    
    // Demo friends - only shown to returning users
    final demoFriends = [
      {'name': 'Sara Hameed', 'id': 'demo_friend_1'},
      {'name': 'Fahad Saeed', 'id': 'demo_friend_2'},
      {'name': 'Alina Tariq', 'id': 'demo_friend_3'},
      {'name': 'Ali Ahmed', 'id': 'demo_friend_4'},
      {'name': 'Zainab Hussain', 'id': 'demo_friend_5'},
    ];
    
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
              : _isNewUser
                  ? _buildNoFriendsView(isDark)
                  : _buildFriendsListView(isDark, currentUserName, demoFriends),
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
    List<Map<String, String>> demoFriends,
  ) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: demoFriends.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == demoFriends.length) {
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
          final friend = demoFriends[index];
          final firstName = (friend['name'] as String).split(' ').first;
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DemoFriendProfileScreen(
                    currentUserName: currentUserName,
                    friendName: friend['name'] as String,
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
