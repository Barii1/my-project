import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/social_provider.dart';
import '../../friends_screen.dart';
import '../../add_friend_screen.dart';
import '../../community_user_profile.dart';

class FriendsSection extends StatelessWidget {
  const FriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<SocialProvider>(
      builder: (context, social, _) {
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
              if (social.friends.isEmpty)
                Text('No friends yet. Start adding!', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF64748B)))
              else
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: social.friends.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == social.friends.length) {
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
                      final name = social.friends[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityUserProfileScreen(username: name, avatar: '👤'),
                          ),
                        ),
                        child: Container(
                          width: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              name.split(' ').first,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
