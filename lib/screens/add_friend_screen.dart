import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  
  List<UserSearchResult> _searchResults = [];
  Map<String, bool> _isFriendCache = {};
  Map<String, String?> _requestStatusCache = {};
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _query = query; // Set query immediately
    });

    try {
      print('🔍 Searching by username prefix: "$query"');
      var results = await _friendService.searchUsersByUsernamePrefix(query);
      if (results.isEmpty) {
        print('⚠️ No username matches, falling back to name search');
        results = await _friendService.searchUsers(query);
      }
      print('📊 Search returned ${results.length} results');
      
      for (var user in results) {
        print('  👤 Found: ${user.fullName} (${user.email})');
      }
      
      // Check friend status for each result
      for (var user in results) {
        // Skip friend status check for demo users to avoid errors
        if (user.userId.startsWith('demo_search_')) {
          _isFriendCache[user.userId] = false;
          _requestStatusCache[user.userId] = null;
        } else {
          final isFriend = await _friendService.isFriend(user.userId);
          final requestStatus = await _friendService.getRequestStatus(user.userId);
          
          _isFriendCache[user.userId] = isFriend;
          _requestStatusCache[user.userId] = requestStatus;
        }
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      
      print('✅ Updated UI with ${results.length} results');
    } catch (e) {
      print('❌ Search error: $e');
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAllUsers() async {
    setState(() => _isSearching = true);
    
    try {
      print('📋 Fetching all users from Firestore...');
      final results = await _friendService.getAllUsers();
      print('📊 Found ${results.length} total users in database');
      
      for (var user in results) {
        print('  👤 ${user.fullName} (${user.email})');
        final isFriend = await _friendService.isFriend(user.userId);
        final requestStatus = await _friendService.getRequestStatus(user.userId);
        
        _isFriendCache[user.userId] = isFriend;
        _requestStatusCache[user.userId] = requestStatus;
      }
      
      setState(() {
        _searchResults = results;
        _searchController.text = ''; // Clear search box
        _query = ''; // Keep query empty so results show
        _isSearching = false;
      });
      
      if (results.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No users found in database. Create another account to test.'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Error fetching all users: $e');
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(UserSearchResult user) async {
    final success = await _friendService.sendFriendRequest(
      toUserId: user.userId,
      toUserName: user.fullName,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _requestStatusCache[user.userId] = 'pending';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${user.fullName}'),
          backgroundColor: const Color(0xFF4DB8A8),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Show all users',
            onPressed: _showAllUsers,
          ),
        ],
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
                onChanged: (v) {
                  setState(() => _query = v.trim());
                  _performSearch(v.trim());
                },
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                    hintText: 'Search by username or name...',
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
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB8A8)))
                : _searchResults.isEmpty && _query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for users',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type a name to find friends',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Or tap the list icon above to see all users',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, i) {
                              final user = _searchResults[i];
                              final isFriend = _isFriendCache[user.userId] ?? false;
                              final requestStatus = _requestStatusCache[user.userId];
                              final isDemoUser = user.userId.startsWith('demo_search_');
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF16213E) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          user.fullName.isNotEmpty 
                                              ? user.fullName.substring(0, 1).toUpperCase()
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : const Color(0xFF34495E),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user.email,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isFriend)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4DB8A8).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Friend',
                                          style: TextStyle(
                                            color: Color(0xFF4DB8A8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    else if (requestStatus == 'pending')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Requested',
                                          style: TextStyle(
                                            color: Color(0xFFF59E0B),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: isDemoUser 
                                            ? () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('This is a demo user for testing'),
                                                    backgroundColor: Color(0xFF3DA89A),
                                                  ),
                                                );
                                              }
                                            : () => _sendFriendRequest(user),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4DB8A8),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
