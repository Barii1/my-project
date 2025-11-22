import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        title: const Text('Add Friend'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SocialProvider>(
              builder: (context, social, _) {
                final results = _query.isEmpty ? <String>[] : social.searchUsers(_query);
                if (_query.isNotEmpty && results.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final user = results[i];
                    final alreadyFriend = social.friends.contains(user);
                    final pending = social.friendRequests.contains(user);
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
                          const Icon(Icons.person_outline, color: Color(0xFF3DA89A)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF34495E),
                              ),
                            ),
                          ),
                          if (alreadyFriend)
                            Text('Friend', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B)))
                          else if (pending)
                            Text('Requested', style: TextStyle(color: const Color(0xFFF59E0B)))
                          else
                            TextButton(
                              onPressed: () {
                                social.sendFriendRequest(user);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Friend request sent to $user')),
                                );
                              },
                              child: const Text('Add'),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
