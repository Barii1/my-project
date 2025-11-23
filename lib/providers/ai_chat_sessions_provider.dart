import 'package:flutter/material.dart';
import '../services/offline_storage_service.dart';

class ChatSession {
  final String id;
  final String subject;
  String lastMessage;
  DateTime updatedAt;
  ChatSession({required this.id, required this.subject, required this.lastMessage, required this.updatedAt});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'lastMessage': lastMessage,
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'],
    subject: json['subject'],
    lastMessage: json['lastMessage'],
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class AiChatSessionsProvider extends ChangeNotifier {
  final List<ChatSession> _sessions = [];
  
  AiChatSessionsProvider() {
    _loadOfflineSessions();
  }
  
  Future<void> _loadOfflineSessions() async {
    final cached = OfflineStorageService.getCachedData('ai_chat_sessions');
    if (cached != null && cached is List) {
      _sessions.clear();
      for (final item in cached) {
        try {
          _sessions.add(ChatSession.fromJson(item as Map<String, dynamic>));
        } catch (_) {}
      }
      notifyListeners();
    }
  }
  
  Future<void> _saveSessions() async {
    final sessionsData = _sessions.map((s) => s.toJson()).toList();
    await OfflineStorageService.cacheData('ai_chat_sessions', sessionsData);
  }

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession startSession(String subject) {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      lastMessage: 'New chat',
      updatedAt: DateTime.now(),
    );
    _sessions.insert(0, session);
    _saveSessions();
    notifyListeners();
    return session;
  }

  void recordMessage(String sessionId, String content, {bool fromUser = true}) {
    final session = _sessions.firstWhere((s) => s.id == sessionId, orElse: () => throw Exception('Session not found'));
    session.lastMessage = content.length > 60 ? '${content.substring(0, 57)}…' : content;
    session.updatedAt = DateTime.now();
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _saveSessions();
    notifyListeners();
  }
}
