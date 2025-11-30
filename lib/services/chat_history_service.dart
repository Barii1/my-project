import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryService {
  static const String _boxName = 'chat_history';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static List<Map<String, dynamic>> getMessages(String sessionId) {
    final data = _box.get(sessionId, defaultValue: []);
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map))
    );
  }

  static Future<void> appendMessage(String sessionId, Map<String, dynamic> message) async {
    final existing = getMessages(sessionId);
    existing.add(message);
    await _box.put(sessionId, existing);
  }

  static Future<void> clearSession(String sessionId) async {
    await _box.delete(sessionId);
  }
}