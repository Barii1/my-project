import 'package:flutter/foundation.dart';

class StatsProvider with ChangeNotifier {
  int _streakDays = 12;
  double _dailyGoalProgress = 0.65; // 0.0 - 1.0
  int _totalXp = 3420;
  final Map<String, double> _subjectAccuracy = {
    'Computer Science': 0.78,
    'Mathematics': 0.85,
  };
  final List<String> _badges = ['gold', 'silver', 'bronze'];

  int get streakDays => _streakDays;
  double get dailyGoalProgress => _dailyGoalProgress;
  int get totalXp => _totalXp;
  Map<String, double> get subjectAccuracy => Map.unmodifiable(_subjectAccuracy);
  List<String> get badges => List.unmodifiable(_badges);

  // Example setters - in a real app you'd fetch/update from a backend
  void setStreak(int days) {
    _streakDays = days;
    notifyListeners();
  }

  void setDailyProgress(double v) {
    _dailyGoalProgress = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setTotalXp(int xp) {
    _totalXp = xp;
    notifyListeners();
  }

  void setSubjectAccuracy(String subject, double val) {
    _subjectAccuracy[subject] = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  void addBadge(String id) {
    _badges.insert(0, id);
    notifyListeners();
  }
}
