import 'package:flutter/material.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import 'ai_tutor_screen.dart';
import 'ai_chat_screen.dart';
import 'history_screen.dart';
import 'quizzes_screen.dart';
import 'community_modern.dart';
import 'home/components/streak_summary.dart';
import 'home/components/progress_cards_row.dart';
import 'home/components/friends_section.dart';
import 'settings_screen_modern.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'daily_quiz_screen.dart';
import 'flashcards_screen.dart';
import 'notes_screen.dart';
import 'daily_goal_screen.dart';
import 'settings/app_usage_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/offline_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import '../services/usage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreenV3 extends StatefulWidget {
  const HomeScreenV3({super.key});

  @override
  State<HomeScreenV3> createState() => _HomeScreenV3State();
}

class _HomeScreenV3State extends State<HomeScreenV3> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _dailyQuizCount = 0;
  int _dailyGoal = 3; // Default value, loaded from prefs
  int _streak = 0; // Dynamic login streak
  DateTime? _sessionStart;
  Timer? _usageTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDailyGoal();
    _updateDailyStreak();
    _beginSession();
    _startUsageTracking();
  }

  String _formatMinutesLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final hrsPart = hours == 1 ? '1 hr' : '$hours hrs';
    return mins == 0 ? hrsPart : '$hrsPart $mins min';
  }

  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final savedDate = prefs.getString('daily_goal_date_$uid') ?? '';
    
    // Load the target goal from preferences
    final targetGoal = prefs.getInt('daily_goal_target_$uid') ?? 3;
    
    // Reset counter if it's a new day
    if (savedDate != dateKey) {
      await prefs.setInt('daily_quiz_count_$uid', 0);
      await prefs.setString('daily_goal_date_$uid', dateKey);
      setState(() {
        _dailyQuizCount = 0;
        _dailyGoal = targetGoal;
      });
    } else {
      setState(() {
        _dailyQuizCount = prefs.getInt('daily_quiz_count_$uid') ?? 0;
        _dailyGoal = targetGoal;
      });
    }
  }

  @override
  void dispose() {
    _endSession();
    _usageTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _beginSession();
      _startUsageTracking();
      _loadDailyGoal(); // Refresh quiz counter when app resumes
      setState(() {}); // Rebuild to update study analytics
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _endSession();
      _usageTimer?.cancel();
      // Sync current day/week usage when app goes to background
      () async {
        try {
          await UsageService.syncTodayToFirestore();
          await UsageService.syncWeekAggregateToFirestore();
        } catch (_) {}
      }();
    }
  }

  void _startUsageTracking() {
    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _saveUsageIncrement();
    });
  }

  Future<void> _saveUsageIncrement() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    
    // Save for today
    final todayKey = 'usage_${uid}_$dateKey';
    final todayCurrent = prefs.getInt(todayKey) ?? 0;
    final capped = (todayCurrent + 60).clamp(0, 24 * 3600); // cap at 24h per day
    await prefs.setInt(todayKey, capped);
  }

  Future<void> _beginSession() async {
    _sessionStart = DateTime.now();
  }

  Future<void> _endSession() async {
    if (_sessionStart == null) return;
    final end = DateTime.now();
    final seconds = end.difference(_sessionStart!).inSeconds;
    _sessionStart = null;
    if (seconds <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final key = 'usage_${uid}_$dateKey';
    final current = prefs.getInt(key) ?? 0;
    final capped = (current + seconds).clamp(0, 24 * 3600);
    await prefs.setInt(key, capped);
    // Best-effort sync to Firestore for cross-device analytics
    try {
      await UsageService.syncTodayToFirestore();
      await UsageService.syncWeekAggregateToFirestore();
    } catch (_) {}
  }

  Future<void> _updateDailyStreak() async {
    // Get streak from Firestore instead of SharedPreferences
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final streakDays = data?['streakDays'] ?? 0;
        if (!mounted) return;
        setState(() => _streak = streakDays);
      } else {
        if (!mounted) return;
        setState(() => _streak = 0);
      }
    } catch (e) {
      // Fallback to 0 on error
      if (!mounted) return;
      setState(() => _streak = 0);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Refresh data when returning to home tab
    if (index == 0) {
      _loadDailyGoal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final name = (auth.fullName?.isNotEmpty ?? false) ? auth.fullName!.split(' ')[0] : 'Learner';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = {
      'name': authProvider.fullName ?? 'Learner',
      'email': authProvider.email ?? ''
    };

    final pages = [
      _buildHomeContent(context, name),
      AITutorScreen(
        onSelectCourse: (course) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIChatScreen(
                course: course,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
        onNavigate: (screen) {
          if (screen == 'history') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate: $screen')));
          }
        },
      ),
      QuizzesScreen(
        onStartQuiz: (categoryId) {
          // Handle quiz category selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Starting quiz for: $categoryId')),
          );
        },
        onNavigate: (screen) {
          if (screen == 'notes') Navigator.of(context).pushNamed('/notes');
        },
      ),
      const CommunityModernScreen(),
      SettingsScreenModern(
        user: user,
        onLogout: () async {
          await authProvider.logout();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Stack(
        children: [
          Column(
            children: [
              const OfflineIndicator(),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, String name) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          _buildWelcomeRow(name),
          const SizedBox(height: 20),
          StreakSummary(streak: _streak),
          const SizedBox(height: 16),
          ProgressCardsRow(
            dailyProgress: (_dailyGoal > 0)
                ? (_dailyQuizCount / _dailyGoal).clamp(0.0, 1.0)
                : 0.0,
          ),
          const SizedBox(height: 20),
          const FriendsSection(),
          const SizedBox(height: 20),
          _buildQuickStartSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeRow(String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Welcome back, $name! 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to continue learning?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  // Re-added quick start section that uses the helper cards below.
  Widget _buildQuickStartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyGoalCard(),
        const SizedBox(height: 20),
        _buildWeeklyProgressGraph(),
        const SizedBox(height: 20),
        _buildRecentBadgesCard(),
        const SizedBox(height: 20),
        _buildQuickStartActionsCard(),
      ],
    );
  }

  Widget _buildDailyGoalCard() {
    final progress = _dailyQuizCount / _dailyGoal;
    final isComplete = _dailyQuizCount >= _dailyGoal;
    
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyGoalScreen()),
        );
        // Reload goal after returning from settings
        _loadDailyGoal();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF4DB8A8), const Color(0xFF3DA89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? const Color(0xFF10B981) : const Color(0xFF4DB8A8))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle : Icons.flag,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Daily Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '$_dailyQuizCount/$_dailyGoal',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isComplete
                ? '🎉 Goal completed! Great work today!'
                : 'Complete ${_dailyGoal - _dailyQuizCount} more ${_dailyGoal - _dailyQuizCount == 1 ? "quiz" : "quizzes"} today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildWeeklyProgressGraph() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;
    const maxMinutes = 5 * 60.0; // 5 hours = 300 minutes

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        UsageService.getWeekSeconds(),
        UsageService.getLast7DaysSeconds(),
      ]),
      builder: (context, snapshot) {
        final List<double> weekMinutes = [];
        int totalSec = 0;
        if (snapshot.hasData && snapshot.data!.length == 2) {
          totalSec = snapshot.data![0] as int; // week seconds
          final last7 = snapshot.data![1] as List<int>; // per-day seconds
          for (final secs in last7) {
            final mins = secs / 60.0;
            weekMinutes.add(mins);
          }
        } else {
          weekMinutes.addAll(List.filled(7, 0.0));
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AppUsageScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: const Color(0xFF2A2E45)) : null,
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3DA89A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.analytics_outlined,
                            color: Color(0xFF3DA89A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Screen Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatMinutesLabel((totalSec / 60).round()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hours studied this week',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final valueMin = weekMinutes[index];
                    final height = (valueMin / maxMinutes) * 120;
                    final isToday = index == currentDayIndex;
                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${days[index]}: ${_formatMinutesLabel(valueMin.round())}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            _formatMinutesLabel(valueMin.round()),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 32,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isToday
                                    ? [const Color(0xFF4DB8A8), const Color(0xFF3DA89A)]
                                    : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                              color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStartActionsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF2A2E45)) : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.quiz_outlined,
            label: 'Weekly Quiz',
            color: const Color(0xFF3B82F6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyQuizScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.style_outlined,
            label: 'Review Flashcards',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlashcardsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.note_alt_outlined,
            label: 'New Note',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotesScreen()),
            ),
          ),
          // Chatbot button removed from home screen
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBadgesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Badges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Icon(Icons.emoji_events, color: Color(0xFF10B981), size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadge('7-day Streak', Icons.local_fire_department, const Color(0xFFFFA726)),
              _buildBadge('Quiz Master', Icons.emoji_events, const Color(0xFFFFD700)),
              _buildBadge('Note Taker', Icons.note_alt, const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        border: isDark ? Border(top: BorderSide(color: const Color(0xFF2A2E45))) : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.access_time, Icons.access_time, 'AI Tutor'),
            _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book, 'Quizzes'),
            _buildNavItem(3, Icons.people_outline, Icons.people, 'Community'),
            _buildNavItem(4, Icons.settings_outlined, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00A3A3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x4000A3A3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 10),
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF00A3A3) : const Color(0xFF99A3B1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF00A3A3) : const Color(0xFF99A3B1),
            ),
          ),
        ],
      ),
    );
  }
}
