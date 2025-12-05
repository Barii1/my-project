import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

class DailyGoalScreen extends StatefulWidget {
  const DailyGoalScreen({super.key});

  @override
  State<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen> {
  int _selectedGoal = 3; // Default: 3 quizzes

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'value': 1,
      'title': 'Beginner',
      'subtitle': '1 quiz per day',
      'icon': Icons.self_improvement,
    },
    {
      'value': 3,
      'title': 'Regular',
      'subtitle': '3 quizzes per day',
      'icon': Icons.directions_run,
    },
    {
      'value': 5,
      'title': 'Dedicated',
      'subtitle': '5 quizzes per day',
      'icon': Icons.fitness_center,
    },
    {
      'value': 7,
      'title': 'Champion',
      'subtitle': '7 quizzes per day',
      'icon': Icons.emoji_events,
    },
    {
      'value': 10,
      'title': 'Legend',
      'subtitle': '10 quizzes per day',
      'icon': Icons.local_fire_department,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentGoal();
  }

  Future<void> _loadCurrentGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    setState(() {
      _selectedGoal = prefs.getInt('daily_goal_target_$uid') ?? 3;
    });
  }

  Future<void> _saveGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    await prefs.setInt('daily_goal_target_$uid', goal);
    setState(() => _selectedGoal = goal);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily goal set to $goal quizzes!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Set Daily Goal'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Choose Your Challenge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select how many quizzes you want to complete each day',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),

          // Goal options
          ..._goalOptions.map((option) {
            final isSelected = _selectedGoal == option['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGoalOption(
                value: option['value'] as int,
                title: option['title'] as String,
                subtitle: option['subtitle'] as String,
                icon: option['icon'] as IconData,
                isSelected: isSelected,
                isDark: isDark,
              ),
            );
          }),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB8A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4DB8A8).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF4DB8A8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your goal resets every day at midnight. Start small and build consistency!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required int value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _saveGoal(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4DB8A8).withOpacity(0.15)
              : (isDark ? const Color(0xFF16213E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4DB8A8)
                : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4DB8A8)
                    : (isDark
                          ? const Color(0xFF2A2E45)
                          : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF4DB8A8),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF34495E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4DB8A8),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
