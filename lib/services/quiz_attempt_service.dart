import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttemptService {
  static final _fs = FirebaseFirestore.instance;

  /// Record a quiz attempt; backend functions award XP/streaks.
  static Future<void> recordAttempt({
    required String userId,
    required String subject,
    required int correct,
    required int total,
    required int xpEarned,
  }) async {
    await _fs.collection('quiz_attempts').add({
      'userId': userId,
      'subject': subject,
      'correct': correct,
      'total': total,
      'xpEarned': xpEarned,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
