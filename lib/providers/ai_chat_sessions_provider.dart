import 'package:flutter/material.dart';

class ChatSession {
  final String id;
  final String subject;
  String lastMessage;
  DateTime updatedAt;
  ChatSession({required this.id, required this.subject, required this.lastMessage, required this.updatedAt});
}

class AiChatSessionsProvider extends ChangeNotifier {
  final List<ChatSession> _sessions = [];

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession startSession(String subject) {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      lastMessage: 'New chat',
      updatedAt: DateTime.now(),
    );
    _sessions.insert(0, session);
    notifyListeners();
    return session;
  }

  void recordMessage(String sessionId, String content, {bool fromUser = true}) {
    final session = _sessions.firstWhere((s) => s.id == sessionId, orElse: () => throw Exception('Session not found'));
    session.lastMessage = content.length > 60 ? content.substring(0, 57) + '…' : content;
    session.updatedAt = DateTime.now();
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }
}
