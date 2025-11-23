import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/chat_thread.dart';
import '../services/offline_storage_service.dart';

class AppStateProvider with ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  // User settings
  bool _pushNotificationsEnabled = true;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  void togglePushNotifications() {
    _pushNotificationsEnabled = !_pushNotificationsEnabled;
    notifyListeners();
  }

  // User Data
  bool _dataSync = true;
  bool get dataSync => _dataSync;

  void toggleDataSync() {
    _dataSync = !_dataSync;
    notifyListeners();
  }

  // App Settings
  bool _autoPlay = true;
  bool get autoPlay => _autoPlay;

  void toggleAutoPlay() {
    _autoPlay = !_autoPlay;
    notifyListeners();
  }

  // Font Size
  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;

  void setTextScaleFactor(double factor) {
    if (_textScaleFactor == factor) return;
    _textScaleFactor = factor;
    notifyListeners();
  }

  // Sound Effects
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  // Language
  String _language = 'English';
  String get language => _language;

  void setLanguage(String lang) {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
  }

  // Flashcards (in-memory)
  final List<Flashcard> _flashcards = [];
  List<Flashcard> get flashcards => List.unmodifiable(_flashcards);

  /// Adds simple flashcards parsed from note title/content.
  /// Parsing heuristic: split content into paragraphs; use first line as front and rest as back.
  void addFlashcardsFromNote(String title, String content) {
    final blocks = content.split(RegExp(r"\n\s*\n")).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (blocks.isEmpty) {
      // fallback: create one flashcard from title and content
      _flashcards.add(Flashcard(front: title, back: content));
    } else {
      for (final b in blocks) {
        final lines = b.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        if (lines.length >= 2) {
          _flashcards.add(Flashcard(front: lines.first, back: lines.sublist(1).join('\n')));
        } else {
          _flashcards.add(Flashcard(front: title, back: lines.first));
        }
      }
    }
    notifyListeners();
    saveFlashcardsToPrefs();
  }

  void clearFlashcards() {
    _flashcards.clear();
    notifyListeners();
    saveFlashcardsToPrefs();
  }

  // Persistence with offline storage
  Future<void> saveFlashcardsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _flashcards.map((f) => {'front': f.front, 'back': f.back}).toList();
      await prefs.setString('flashcards', jsonEncode(list));
      
      // Also save to offline storage
      await OfflineStorageService.saveFlashcardDeck(
        'user_flashcards',
        list.map((item) => {'front': item['front'] as String, 'back': item['back'] as String}).toList(),
      );
    } catch (_) {}
  }

  Future<void> loadFlashcardsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('flashcards');
      
      List<dynamic>? data;
      
      if (jsonStr != null) {
        data = jsonDecode(jsonStr) as List<dynamic>;
      } else {
        // Try loading from offline storage
        final offlineCards = OfflineStorageService.getFlashcardDeck('user_flashcards');
        if (offlineCards != null) {
          data = offlineCards;
        }
      }
      
      if (data != null) {
        _flashcards.clear();
        for (final item in data) {
          final map = item as Map<String, dynamic>;
          _flashcards.add(Flashcard(front: map['front'] ?? '', back: map['back'] ?? ''));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // Recent Chats
  final List<ChatThread> _recentChats = [];
  List<ChatThread> get recentChats => List.unmodifiable(_recentChats);

  void addRecentChat(ChatThread chat) {
    _recentChats.removeWhere((c) => c.id == chat.id);
    _recentChats.insert(0, chat);
    notifyListeners();
    saveRecentChatsToPrefs();
  }

  void removeRecentChat(String id) {
    _recentChats.removeWhere((c) => c.id == id);
    notifyListeners();
    saveRecentChatsToPrefs();
  }

  Future<void> saveRecentChatsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _recentChats.map((c) => c.toJson()).toList();
      await prefs.setString('recent_chats', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> loadRecentChatsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('recent_chats');
      if (jsonStr == null) return;
      final data = jsonDecode(jsonStr) as List<dynamic>;
      _recentChats.clear();
      for (final item in data) {
        final map = item as Map<String, dynamic>;
        _recentChats.add(ChatThread.fromJson(map));
      }
      notifyListeners();
    } catch (_) {}
  }
}