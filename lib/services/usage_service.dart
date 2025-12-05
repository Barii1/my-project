import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageService {
  static String _uidPrefix() {
    final u = FirebaseAuth.instance.currentUser;
    return (u?.uid ?? 'anon');
  }

  static String _keyFor(DateTime d) {
    final uid = _uidPrefix();
    return 'usage_${uid}_${d.year}-${d.month}-${d.day}';
  }

  static Future<int> getTodaySeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final sec = prefs.getInt(_keyFor(DateTime(now.year, now.month, now.day))) ?? 0;
    return sec.clamp(0, 24 * 3600);
  }

  static Future<int> getWeekSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int sum = 0;
    // Compute week starting Monday to Sunday of current week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    for (int i = 0; i < 7; i++) {
      final keyDate = startOfWeek.add(Duration(days: i));
      final sec = prefs.getInt(_keyFor(keyDate)) ?? 0;
      sum += sec;
    }
    // Clamp theoretical max 7 * 24h
    return sum.clamp(0, 7 * 24 * 3600);
  }

  static Future<List<int>> getLast7DaysSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    // Return Monday..Sunday of current week
    final startOfWeek = base.subtract(Duration(days: base.weekday - 1));
    final result = <int>[];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final sec = prefs.getInt(_keyFor(day)) ?? 0;
      result.add(sec.clamp(0, 24 * 3600));
    }
    return result;
  }

  /// Sync today's usage seconds to Firestore under
  /// `users/{uid}/usage/{YYYY-MM-DD}` with fields: { seconds, updatedAt }.
  /// Writes only if user is signed in.
  static Future<void> syncTodayToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
        final key = _keyFor(today);
      final secs = (prefs.getInt(key) ?? 0).clamp(0, 24 * 3600);
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('usage')
          .doc('${today.year}-${today.month}-${today.day}');
      await ref.set({
        'seconds': secs,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      // best-effort; avoid UI crash
      // ignore errors silently
    }
  }

  /// Optional: Sync the current week's aggregate seconds to `users/{uid}`.
  static Future<void> syncWeekAggregateToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final weekSecs = await getWeekSeconds();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'weekUsageSeconds': weekSecs, 'weekUsageUpdatedAt': Timestamp.now()}, SetOptions(merge: true));
    } catch (_) {}
  }
}
