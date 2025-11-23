import 'package:hive_flutter/hive_flutter.dart';

class OfflineStorageService {
  static const String _quizBox = 'quiz_data';
  static const String _flashcardBox = 'flashcard_data';
  static const String _notesBox = 'notes_data';
  static const String _progressBox = 'progress_data';
  static const String _cacheBox = 'cache_data';
  static const String _authBox = 'auth_data';
  static const String _communityBox = 'community_data';

  // Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open all boxes
    await Future.wait([
      Hive.openBox(_quizBox),
      Hive.openBox(_flashcardBox),
      Hive.openBox(_notesBox),
      Hive.openBox(_progressBox),
      Hive.openBox(_cacheBox),
      Hive.openBox(_authBox),
      Hive.openBox(_communityBox),
    ]);
  }

  // Quiz Data Methods
  static Box get _quiz => Hive.box(_quizBox);

  static Future<void> saveQuizCategory(String categoryId, Map<String, dynamic> data) async {
    await _quiz.put(categoryId, data);
  }

  static Map<String, dynamic>? getQuizCategory(String categoryId) {
    final data = _quiz.get(categoryId);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  static Future<void> saveQuizProgress(String quizId, Map<String, dynamic> progress) async {
    await _quiz.put('progress_$quizId', progress);
  }

  static Map<String, dynamic>? getQuizProgress(String quizId) {
    final data = _quiz.get('progress_$quizId');
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  // Flashcard Methods
  static Box get _flashcards => Hive.box(_flashcardBox);

  static Future<void> saveFlashcardDeck(String deckId, List<Map<String, String>> cards) async {
    await _flashcards.put(deckId, cards);
  }

  static List<Map<String, String>>? getFlashcardDeck(String deckId) {
    final data = _flashcards.get(deckId);
    if (data != null) {
      return List<Map<String, String>>.from(
        (data as List).map((card) => Map<String, String>.from(card as Map))
      );
    }
    return null;
  }

  static Future<void> saveAllFlashcards(Map<String, List<Map<String, String>>> allDecks) async {
    for (var entry in allDecks.entries) {
      await saveFlashcardDeck(entry.key, entry.value);
    }
  }

  // Notes Methods
  static Box get _notes => Hive.box(_notesBox);

  static Future<void> saveNote(String noteId, Map<String, dynamic> note) async {
    await _notes.put(noteId, note);
  }

  static Map<String, dynamic>? getNote(String noteId) {
    final data = _notes.get(noteId);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  static List<Map<String, dynamic>> getAllNotes() {
    final notes = <Map<String, dynamic>>[];
    for (var key in _notes.keys) {
      final note = _notes.get(key);
      if (note != null) {
        notes.add(Map<String, dynamic>.from(note as Map));
      }
    }
    return notes;
  }

  static Future<void> deleteNote(String noteId) async {
    await _notes.delete(noteId);
  }

  // Progress Data Methods
  static Box get _progress => Hive.box(_progressBox);

  static Future<void> saveUserProgress(Map<String, dynamic> progress) async {
    await _progress.put('user_progress', progress);
  }

  static Map<String, dynamic>? getUserProgress() {
    final data = _progress.get('user_progress');
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  static Future<void> saveStreak(int streak) async {
    await _progress.put('streak', streak);
  }

  static int getStreak() {
    return _progress.get('streak', defaultValue: 0) as int;
  }

  static Future<void> saveXP(int xp) async {
    await _progress.put('xp', xp);
  }

  static int getXP() {
    return _progress.get('xp', defaultValue: 0) as int;
  }

  static Future<void> saveDailyGoal(int goal) async {
    await _progress.put('daily_goal', goal);
  }

  static int getDailyGoal() {
    return _progress.get('daily_goal', defaultValue: 0) as int;
  }

  // Cache Methods (for temporary data)
  static Box get _cache => Hive.box(_cacheBox);

  static Future<void> cacheData(String key, dynamic data) async {
    await _cache.put(key, {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static dynamic getCachedData(String key, {Duration maxAge = const Duration(hours: 24)}) {
    final cached = _cache.get(key);
    if (cached != null) {
      final timestamp = cached['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      if (age < maxAge.inMilliseconds) {
        return cached['data'];
      } else {
        // Cache expired, delete it
        _cache.delete(key);
      }
    }
    return null;
  }

  static Future<void> clearCache() async {
    await _cache.clear();
  }

  // Activity History
  static Future<void> saveActivity(Map<String, dynamic> activity) async {
    final activities = getActivities();
    activities.insert(0, activity);
    
    // Keep only last 100 activities
    if (activities.length > 100) {
      activities.removeRange(100, activities.length);
    }
    
    await _progress.put('activities', activities);
  }

  static List<Map<String, dynamic>> getActivities() {
    final data = _progress.get('activities', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map))
    );
  }

  // Clear all data (for logout or reset)
  static Future<void> clearAllData() async {
    await Future.wait([
      _quiz.clear(),
      _flashcards.clear(),
      _notes.clear(),
      _progress.clear(),
      _cache.clear(),
      _auth.clear(),
      _community.clear(),
    ]);
  }

  // Authentication Methods
  static Box get _auth => Hive.box(_authBox);

  static Future<void> saveUserCredentials(Map<String, dynamic> user) async {
    await _auth.put('user', user);
    await _auth.put('last_login', DateTime.now().millisecondsSinceEpoch);
    await _auth.put('is_logged_in', true);
  }

  static Map<String, dynamic>? getUserCredentials() {
    final data = _auth.get('user');
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  static bool isUserLoggedIn() {
    return _auth.get('is_logged_in', defaultValue: false) as bool;
  }

  static Future<void> logout() async {
    await _auth.put('is_logged_in', false);
  }

  static int? getLastLoginTime() {
    return _auth.get('last_login') as int?;
  }

  // Community/Social Data
  static Box get _community => Hive.box(_communityBox);

  static Future<void> savePosts(List<Map<String, dynamic>> posts) async {
    await _community.put('posts', posts);
  }

  static List<Map<String, dynamic>> getPosts() {
    final data = _community.get('posts', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map))
    );
  }

  static Future<void> saveFriends(List<String> friends) async {
    await _community.put('friends', friends);
  }

  static List<String> getFriends() {
    final data = _community.get('friends', defaultValue: []);
    return List<String>.from(data as List);
  }

  static Future<void> saveLikedPosts(Set<String> likedPosts) async {
    await _community.put('liked_posts', likedPosts.toList());
  }

  static Set<String> getLikedPosts() {
    final data = _community.get('liked_posts', defaultValue: []);
    return Set<String>.from(data as List);
  }

  static Future<void> saveBookmarkedPosts(Set<String> bookmarked) async {
    await _community.put('bookmarked_posts', bookmarked.toList());
  }

  static Set<String> getBookmarkedPosts() {
    final data = _community.get('bookmarked_posts', defaultValue: []);
    return Set<String>.from(data as List);
  }

  // Quiz Categories and Questions
  static Future<void> saveQuizCategories(List<Map<String, dynamic>> categories) async {
    await _quiz.put('categories', categories);
  }

  static List<Map<String, dynamic>> getQuizCategories() {
    final data = _quiz.get('categories', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map))
    );
  }

  static Future<void> saveQuizQuestions(String categoryId, List<Map<String, dynamic>> questions) async {
    await _quiz.put('questions_$categoryId', questions);
  }

  static List<Map<String, dynamic>> getQuizQuestions(String categoryId) {
    final data = _quiz.get('questions_$categoryId', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item as Map))
    );
  }

  // Get storage size info
  static Map<String, int> getStorageInfo() {
    return {
      'quiz_items': _quiz.length,
      'flashcard_decks': _flashcards.length,
      'notes': _notes.length,
      'progress_items': _progress.length,
      'cache_items': _cache.length,
      'auth_items': _auth.length,
      'community_items': _community.length,
    };
  }
}
