import 'package:flutter/foundation.dart';

class StatsProvider with ChangeNotifier {
  int _streakDays = 0;
  double _dailyGoalProgress = 0.0; // 0.0 - 1.0
  int _totalXp = 0;
  final Map<String, double> _subjectAccuracy = {
    'Computer Science': 0.0,
    'Mathematics': 0.0,
    'General Knowledge': 0.0,
    'Data Structures': 0.0,
    'Algorithms': 0.0,
    'Science': 0.0,
  };
  final List<String> _badges = [];
  final List<String> _earnedBadges = [];
  
  // Weekly performance data (dynamic)
  final List<Map<String, Object>> _weeklyData = [
    {'day': 'Mon', 'score': 75.0},
    {'day': 'Tue', 'score': 82.0},
    {'day': 'Wed', 'score': 78.0},
    {'day': 'Thu', 'score': 88.0},
    {'day': 'Fri', 'score': 85.0},
    {'day': 'Sat', 'score': 92.0},
    {'day': 'Sun', 'score': 87.0},
  ];

  int get streakDays => _streakDays;
  double get dailyGoalProgress => _dailyGoalProgress;
  int get totalXp => _totalXp;
  Map<String, double> get subjectAccuracy => Map.unmodifiable(_subjectAccuracy);
  List<String> get badges => List.unmodifiable(_badges);
  List<String> get earnedBadges => List.unmodifiable(_earnedBadges);
  List<Map<String, Object>> get weeklyData => List.unmodifiable(_weeklyData);

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

  void addXp(int amount) {
    _totalXp += amount;
    // Update daily progress based on XP gained (10 XP = 1% progress)
    _dailyGoalProgress = (_dailyGoalProgress + (amount / 1000)).clamp(0.0, 1.0);
    notifyListeners();
  }

  void setSubjectAccuracy(String subject, double val) {
    _subjectAccuracy[subject] = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  void updateSubjectAccuracy(String subject, int correct, int total) {
    if (total == 0) return;
    final newAccuracy = correct / total;
    // Weighted average with previous accuracy
    final current = _subjectAccuracy[subject] ?? 0.5;
    _subjectAccuracy[subject] = ((current * 0.7) + (newAccuracy * 0.3)).clamp(0.0, 1.0);
    notifyListeners();
  }

  void addBadge(String id) {
    if (!_earnedBadges.contains(id)) {
      _earnedBadges.insert(0, id);
      _badges.insert(0, id);
      notifyListeners();
    }
  }

  void completeQuiz(String subject, int score, int total) {
    // XP awarding handled by backend; do not mutate locally.
    
    // Update subject accuracy
    updateSubjectAccuracy(subject, score, total);
    
    // Update weekly data (add to today's score)
    final today = DateTime.now().weekday - 1; // 0-6 for Mon-Sun
    if (today < _weeklyData.length) {
      final currentScore = _weeklyData[today]['score'] as double;
      final newScore = ((currentScore + (score / total * 100)) / 2).clamp(0.0, 100.0);
      _weeklyData[today] = {
        'day': _weeklyData[today]['day'] as String,
        'score': newScore,
      };
    }
    
    // Check for badge unlocks
    if (score == total && !_earnedBadges.contains('Perfect Score')) {
      addBadge('Perfect Score');
    }
    
    if (_totalXp > 5000 && !_earnedBadges.contains('XP Legend')) {
      addBadge('XP Legend');
    }
    
    // Streak logic handled by backend; keep UI static here.
    
    notifyListeners();
  }
  
  // Demo simulation removed in non-demo mode.
}
