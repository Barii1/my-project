import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// XP rewards and caps
class XpRewards {
  // Core daily actions
  static const int firstLoginOfDay = 10;
  static const int quizShortCompleted = 15; // <= 5 questions
  static const int quizNormalCompleted = 25; // 6–15 questions
  static const int quizLongCompleted = 40; // > 15 questions
  static const int aiExplanationReviewed = 10;
  static const int studySessionCompleted = 20; // 10–15 min
  static const int noteOrFlashcardCreated = 10;

  // Quality/performance bonuses
  static const int quizScore60 = 5;
  static const int quizScore80 = 10;
  static const int quizScore100 = 20;
  static const int noQuestionsSkipped = 10;

  // Streak bonuses (one-time per threshold)
  static const int streak3Days = 20;
  static const int streak7Days = 50;
  static const int streak14Days = 80;
  static const int streak30Days = 150;

  // AI tutor bonuses
  static const int firstMeaningfulAiQuestionOfDay = 10;
  static const int aiAnswerMarkedHelpful = 5;
  static const int aiStudySessionCompleted = 15; // e.g. 3 Q&A in a row

  // Milestones (achievements)
  static const int firstQuizCompleted = 30;
  static const int tenQuizzesCompleted = 80;
  static const int reached1000Xp = 50;
  static const int firstQuizInNewSubject = 25;
  static const int fiveAiSessionsInWeek = 60;

  // Caps
  static const int maxDailyXp = 300;
  static const int maxDailyAiXp = 40;
}

class _UserXpState {
  int xp;
  int dailyXp;
  int dailyAiXp;
  DateTime? dailyXpDate; // stored midnight-based
  int streakDays;
  DateTime? lastActiveDate;
  Map<String, bool> achievements;
  int quizCount;
  int aiSessionsWeekCount;
  DateTime? aiWeekStartDate; // week window for AI sessions milestone

  _UserXpState({
    required this.xp,
    required this.dailyXp,
    required this.dailyAiXp,
    required this.dailyXpDate,
    required this.streakDays,
    required this.lastActiveDate,
    required this.achievements,
    required this.quizCount,
    required this.aiSessionsWeekCount,
    required this.aiWeekStartDate,
  });

  factory _UserXpState.fromFirestore(Map<String, dynamic>? data) {
    final d = data ?? {};
    return _UserXpState(
      xp: (d['xp'] as int?) ?? 0,
      dailyXp: (d['dailyXp'] as int?) ?? 0,
      dailyAiXp: (d['dailyAiXp'] as int?) ?? 0,
      dailyXpDate: (d['dailyXpDate'] is Timestamp)
          ? (d['dailyXpDate'] as Timestamp).toDate()
          : null,
      streakDays: (d['streakDays'] as int?) ?? 0,
      lastActiveDate: (d['lastActiveDate'] is Timestamp)
          ? (d['lastActiveDate'] as Timestamp).toDate()
          : null,
      achievements: (d['achievements'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v == true)) ??
          <String, bool>{},
      quizCount: (d['quizCount'] as int?) ?? 0,
        aiSessionsWeekCount: (d['aiSessionsWeekCount'] as int?) ?? 0,
        aiWeekStartDate: (d['aiWeekStartDate'] is Timestamp)
          ? (d['aiWeekStartDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'xp': xp,
        'dailyXp': dailyXp,
        'dailyAiXp': dailyAiXp,
        'dailyXpDate': dailyXpDate != null ? Timestamp.fromDate(dailyXpDate!) : null,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
        'achievements': achievements,
        'quizCount': quizCount,
        'aiSessionsWeekCount': aiSessionsWeekCount,
        'aiWeekStartDate': aiWeekStartDate != null ? Timestamp.fromDate(aiWeekStartDate!) : null,
      }..removeWhere((key, value) => value == null);
}

class _StateRef {
  final DocumentReference<Map<String, dynamic>> ref;
  final _UserXpState state;
  _StateRef(this.ref, this.state);
}

class XpService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  XpService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> awardXpForLogin() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;

    _resetDailyIfNewDay(state);

    final now = DateTime.now();
    final lastActive = state.lastActiveDate;
    final isFirstLoginToday = lastActive == null || !_isSameDay(_midnight(now), _midnight(lastActive));

    // Streak recompute
    state = _updateStreak(state, now);

    int grant = 0;
    if (isFirstLoginToday) {
      grant += XpRewards.firstLoginOfDay;
    }

    // Streak milestones
    grant += _applyStreakMilestones(state);

    await _applyXp(stateRef, state, grant, isAi: false);
  }

  Future<void> awardXpForQuizCompletion({
    required int questionCount,
    required double scorePercent,
    required bool noSkippedQuestions,
    String? subjectId,
  }) async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;

    _resetDailyIfNewDay(state);

    int grant = 0;
    if (questionCount <= 5) {
      grant += XpRewards.quizShortCompleted;
    } else if (questionCount <= 15) {
      grant += XpRewards.quizNormalCompleted;
    } else {
      grant += XpRewards.quizLongCompleted;
    }

    // Performance bonuses
    if (scorePercent >= 100) {
      grant += XpRewards.quizScore100;
    } else if (scorePercent >= 80) {
      grant += XpRewards.quizScore80;
    } else if (scorePercent >= 60) {
      grant += XpRewards.quizScore60;
    }
    if (noSkippedQuestions) {
      grant += XpRewards.noQuestionsSkipped;
    }

    // Milestones
    state.quizCount += 1;
    grant += _applyOneTimeAchievement(state, 'completedFirstQuiz', XpRewards.firstQuizCompleted);
    if (state.quizCount >= 10) {
      grant += _applyOneTimeAchievement(state, 'completed10Quizzes', XpRewards.tenQuizzesCompleted);
    }
    if (subjectId != null) {
      grant += _applyOneTimeAchievement(state, 'firstQuizInSubject_$subjectId', XpRewards.firstQuizInNewSubject);
    }

    debugPrint('XP: quiz grant=$grant (questions=$questionCount, scorePercent=$scorePercent, noSkipped=$noSkippedQuestions)');

    await _applyXp(stateRef, state, grant, isAi: false);
  }

  Future<void> awardXpForAiQuestion({required bool isFirstMeaningfulQuestionToday}) async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);

    int grant = 0;
    if (isFirstMeaningfulQuestionToday) {
      grant += XpRewards.firstMeaningfulAiQuestionOfDay;
    }

    await _applyXp(stateRef, state, grant, isAi: true);
  }

  /// Award XP when user reviews AI explanation (e.g., taps "View explanation" or scrolls fully).
  Future<void> awardXpForAiExplanationReviewed() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);
    await _applyXp(stateRef, state, XpRewards.aiExplanationReviewed, isAi: true);
  }

  Future<void> awardXpForAiHelpfulMark() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);
    await _applyXp(stateRef, state, XpRewards.aiAnswerMarkedHelpful, isAi: true);
  }

  Future<void> awardXpForStudySession() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);
    await _applyXp(stateRef, state, XpRewards.studySessionCompleted, isAi: false);
  }

  /// Award XP for an AI study session (e.g., 3 Q&A in a row) and track weekly milestone.
  Future<void> awardXpForAiStudySessionCompleted() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);

    // Maintain a rolling week window starting on the stored aiWeekStartDate (or today if null/old)
    final today = _midnight(DateTime.now());
    final weekStart = state.aiWeekStartDate == null ? today : _midnight(state.aiWeekStartDate!);
    if (!_isSameWeek(weekStart, today)) {
      state.aiWeekStartDate = today;
      state.aiSessionsWeekCount = 0;
    }
    state.aiSessionsWeekCount += 1;

    int grant = XpRewards.aiStudySessionCompleted;
    // Milestone: five AI sessions in the week
    if (state.aiSessionsWeekCount >= 5) {
      grant += _applyOneTimeAchievement(state, 'fiveAiSessionsInWeek_${_weekKey(today)}', XpRewards.fiveAiSessionsInWeek);
    }

    await _applyXp(stateRef, state, grant, isAi: true);
  }

  Future<void> awardXpForNoteOrFlashcardCreated() async {
    final stateRef = await _loadUserXpState();
    if (stateRef == null) return;
    var state = stateRef.state;
    _resetDailyIfNewDay(state);
    await _applyXp(stateRef, state, XpRewards.noteOrFlashcardCreated, isAi: false);
  }

  // Helpers
  Future<_StateRef?> _loadUserXpState() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final ref = _firestore.collection('users').doc(user.uid);
    try {
      final snap = await ref.get();
      final state = _UserXpState.fromFirestore(snap.data());
      return _StateRef(ref, state);
    } catch (e) {
      debugPrint('XP: load error $e');
      return _StateRef(ref, _UserXpState(
        xp: 0,
        dailyXp: 0,
        dailyAiXp: 0,
        dailyXpDate: null,
        streakDays: 0,
        lastActiveDate: null,
        achievements: {},
        quizCount: 0,
        aiSessionsWeekCount: 0,
        aiWeekStartDate: null,
      ));
    }
  }

  Future<void> _saveUserXpState(DocumentReference<Map<String, dynamic>> ref, _UserXpState state) async {
    try {
      final data = state.toMap();
      data['updatedAt'] = Timestamp.now();
      await ref.set(data, SetOptions(merge: true));
      debugPrint('XP: saved state xp=${state.xp}, dailyXp=${state.dailyXp}, streak=${state.streakDays}');
    } catch (e) {
      debugPrint('XP: save error $e');
    }
  }

  Future<void> _applyXp(
    _StateRef stateRef,
    _UserXpState state,
    int grant,
    {required bool isAi}
  ) async {
    if (grant <= 0) {
      // still update activity dates
      state.lastActiveDate = DateTime.now();
      state.dailyXpDate = _midnight(DateTime.now());
      debugPrint('XP: grant<=0, updating dates only');
      return _saveUserXpState(stateRef.ref, state);
    }

    // Respect caps
    final nowMidnight = _midnight(DateTime.now());
    state.dailyXpDate = nowMidnight;
    final remainingDaily = XpRewards.maxDailyXp - state.dailyXp;
    int applied = grant.clamp(0, remainingDaily);
    if (isAi) {
      final remainingAi = XpRewards.maxDailyAiXp - state.dailyAiXp;
      applied = applied.clamp(0, remainingAi);
      state.dailyAiXp += applied;
    }

    state.dailyXp += applied;
    state.xp += applied;
    debugPrint('XP: applied=$applied, new xp=${state.xp}, dailyXp=${state.dailyXp}');

    // Milestone: reached 1000 XP
    if (state.xp >= 1000) {
      final milestoneGrant = _applyOneTimeAchievement(state, 'reached1000Xp', XpRewards.reached1000Xp);
      if (milestoneGrant > 0) {
        final remainingDaily2 = XpRewards.maxDailyXp - state.dailyXp;
        final inc2 = milestoneGrant.clamp(0, remainingDaily2);
        state.dailyXp += inc2;
        state.xp += inc2;
      }
    }

    state.lastActiveDate = DateTime.now();
    await _saveUserXpState(stateRef.ref, state);
  }

  void _resetDailyIfNewDay(_UserXpState state) {
    final todayMidnight = _midnight(DateTime.now());
    if (state.dailyXpDate == null || !_isSameDay(state.dailyXpDate!, todayMidnight)) {
      state.dailyXpDate = todayMidnight;
      state.dailyXp = 0;
      state.dailyAiXp = 0;
    }
  }

  _UserXpState _updateStreak(_UserXpState state, DateTime now) {
    final today = _midnight(now);
    final last = state.lastActiveDate != null ? _midnight(state.lastActiveDate!) : null;
    if (last == null) {
      // First ever login - don't give a streak yet
      // Streak starts at 0 and will become 1 on their next login if consecutive
      state.streakDays = 0;
    } else if (_isSameDay(last, today)) {
      // same day, keep current streak
    } else if (_isSameDay(last, today.subtract(const Duration(days: 1)))) {
      // consecutive day - increment streak
      state.streakDays += 1;
    } else {
      // Missed a day - reset to 1 (today counts as new streak start)
      state.streakDays = 1;
    }
    state.lastActiveDate = today;
    return state;
  }

  int _applyStreakMilestones(_UserXpState state) {
    int grant = 0;
    if (state.streakDays >= 3) {
      grant += _applyOneTimeAchievement(state, 'streak3Days', XpRewards.streak3Days);
    }
    if (state.streakDays >= 7) {
      grant += _applyOneTimeAchievement(state, 'streak7Days', XpRewards.streak7Days);
    }
    if (state.streakDays >= 14) {
      grant += _applyOneTimeAchievement(state, 'streak14Days', XpRewards.streak14Days);
    }
    if (state.streakDays >= 30) {
      grant += _applyOneTimeAchievement(state, 'streak30Days', XpRewards.streak30Days);
    }
    return grant;
  }

  int _applyOneTimeAchievement(_UserXpState state, String key, int reward) {
    if (state.achievements[key] == true) return 0;
    state.achievements[key] = true;
    return reward;
  }

  DateTime _midnight(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  bool _isSameWeek(DateTime start, DateTime day) {
    // Compare ISO week by calculating difference in days
    final diff = day.difference(start).inDays;
    return diff >= 0 && diff < 7;
  }
  String _weekKey(DateTime day) {
    final start = _midnight(day);
    return '${start.year}-${start.month}-${start.day}';
  }
}

/*
Integration examples:

// In LoginScreen, after successful signIn and before navigation:
// await XpService().awardXpForLogin();

// In quiz completion handler (e.g., on Done):
// await XpService().awardXpForQuizCompletion(
//   questionCount: quiz.questions.length,
//   scorePercent: scorePercent,
//   noSkippedQuestions: noSkipped,
//   subjectId: courseId,
// );

// In AI Chat screen:
// - When sending first meaningful question of the day:
// await XpService().awardXpForAiQuestion(isFirstMeaningfulQuestionToday: true);
// - When marking an answer helpful:
// await XpService().awardXpForAiHelpfulMark();

// For a 10–15 minute study session end:
// await XpService().awardXpForStudySession();

// When user creates a note or flashcard:
// await XpService().awardXpForNoteOrFlashcardCreated();
*/
