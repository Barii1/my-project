import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';

class SocialProvider extends ChangeNotifier {
  // Simple in-memory post state
  final Map<String, int> _likeCounts = {
    'post1': 42,
    'post2': 38,
    'post3': 27,
  };
  final Map<String, int> _commentCounts = {
    'post1': 12,
    'post2': 9,
    'post3': 15,
  };
  final Map<String, List<_Comment>> _comments = {
    'post1': [
      _Comment(author: 'Sarah K.', avatar: '🎯', text: 'Great post! This really helped me understand the concept better.'),
      _Comment(author: 'Mike T.', avatar: '💡', text: 'Thanks for sharing! Do you have any resources on this topic?'),
    ],
    'post2': [
      _Comment(author: 'Emma L.', avatar: '📚', text: 'This is exactly what I was looking for. Appreciate the detailed explanation!'),
    ],
    'post3': [],
  };
  final Map<String, _PostMeta> _posts = {
    'post1': _PostMeta(
      author: 'Alex Morgan',
      avatar: '🎓',
      time: '3h ago',
      content: 'Just aced my Algorithms exam! The dynamic programming section on this app really helped. Thank you! 💯',
      hasImage: false,
    ),
    'post2': _PostMeta(
      author: 'Jordan Lee',
      avatar: '💻',
      time: '5h ago',
      content: 'Created comprehensive notes on Binary Search Trees. Check them out in the notes section!',
      hasImage: true,
    ),
    'post3': _PostMeta(
      author: 'Emily Chen',
      avatar: '📚',
      time: '1d ago',
      content: 'Looking for study partners for the upcoming Discrete Math exam. Anyone interested?',
      hasImage: false,
    ),
  };
  final Set<String> _likedPosts = {};
  final Set<String> _bookmarkedPosts = {};
  List<_PostEntry> _cachedBookmarkedEntries = const [];

  SocialProvider() {
    _loadOfflineData();
    _rebuildBookmarkCache();
  }

  void _loadOfflineData() {
    // Load liked and bookmarked posts from offline storage
    final likedPosts = OfflineStorageService.getLikedPosts();
    _likedPosts.addAll(likedPosts);
    
    final bookmarkedPosts = OfflineStorageService.getBookmarkedPosts();
    _bookmarkedPosts.addAll(bookmarkedPosts);
    
    final friends = OfflineStorageService.getFriends();
    if (friends.isNotEmpty) {
      _friends.clear();
      _friends.addAll(friends);
    }
  }

  // Friends state - now managed via Firestore (no hardcoded data)
  final List<String> _friends = [];
  final List<String> _friendRequests = [];
  final List<String> _allUsers = [];

  int likeCount(String postId) => _likeCounts[postId] ?? 0;
  bool isLiked(String postId) => _likedPosts.contains(postId);
  bool isBookmarked(String postId) => _bookmarkedPosts.contains(postId);
  int commentCount(String postId) => _commentCounts[postId] ?? 0;
  List<_Comment> commentsFor(String postId) => List.unmodifiable(_comments[postId] ?? const []);
  _PostMeta? meta(String postId) => _posts[postId];
  List<_PostEntry> metaEntriesWhereBookmarked() => _cachedBookmarkedEntries;

  void toggleLike(String postId) {
    if (isLiked(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = ( _likeCounts[postId] ?? 0) + 1;
    }
    OfflineStorageService.saveLikedPosts(_likedPosts);
    notifyListeners();
  }

  void toggleBookmark(String postId) {
    if (isBookmarked(postId)) {
      _bookmarkedPosts.remove(postId);
    } else {
      _bookmarkedPosts.add(postId);
    }
    _rebuildBookmarkCache();
    OfflineStorageService.saveBookmarkedPosts(_bookmarkedPosts);
    notifyListeners();
  }

  void _rebuildBookmarkCache() {
    _cachedBookmarkedEntries = _bookmarkedPosts.map((id) {
      final m = _posts[id];
      if (m == null) return null;
      return _PostEntry(id: id, meta: PostMetaView.from(m));
    }).whereType<_PostEntry>().toList(growable: false);
  }

  // For potential selectors without exposing private types
  List<String> bookmarkedIds() => List.unmodifiable(_bookmarkedPosts);

  void addComment(String postId, String author, String avatar, String text) {
    final list = _comments.putIfAbsent(postId, () => []);
    list.add(_Comment(author: author, avatar: avatar, text: text));
    _commentCounts[postId] = ( _commentCounts[postId] ?? 0 ) + 1;
    notifyListeners();
  }

  List<String> get friends => List.unmodifiable(_friends);
  List<String> get friendRequests => List.unmodifiable(_friendRequests);

  void acceptFriend(String name) {
    if (_friendRequests.remove(name)) {
      if (!_friends.contains(name)) _friends.add(name);
      OfflineStorageService.saveFriends(_friends);
      notifyListeners();
    }
  }

  void declineFriend(String name) {
    if (_friendRequests.remove(name)) {
      notifyListeners();
    }
  }

  void sendFriendRequest(String name) {
    if (!_friends.contains(name) && !_friendRequests.contains(name)) {
      _friendRequests.add(name);
      notifyListeners();
    }
  }

  List<String> searchUsers(String query) {
    final q = query.toLowerCase();
    return _allUsers.where((u) => u.toLowerCase().contains(q)).toList();
  }
}

class _PostEntry {
  final String id;
  final PostMetaView meta;
  _PostEntry({required this.id, required this.meta});
}

class _PostMeta {
  final String author;
  final String avatar;
  final String time;
  final String content;
  final bool hasImage;
  _PostMeta({required this.author, required this.avatar, required this.time, required this.content, required this.hasImage});
}

class PostMetaView {
  final String author;
  final String avatar;
  final String time;
  final String content;
  final bool hasImage;
  PostMetaView({required this.author, required this.avatar, required this.time, required this.content, required this.hasImage});
  factory PostMetaView.from(_PostMeta m) => PostMetaView(author: m.author, avatar: m.avatar, time: m.time, content: m.content, hasImage: m.hasImage);
}

class _Comment {
  final String author;
  final String avatar;
  final String text;
  _Comment({required this.author, required this.avatar, required this.text});
}
