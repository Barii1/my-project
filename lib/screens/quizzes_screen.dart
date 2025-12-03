import 'package:flutter/material.dart';
import 'sub_topics_screen.dart';
// import removed: mixed_quiz_screen.dart

typedef StartQuizCallback = void Function(String categoryId);
typedef NavigateCallback = void Function(String screen);

class QuizzesScreen extends StatefulWidget {
  final StartQuizCallback onStartQuiz;
  final NavigateCallback onNavigate;

  const QuizzesScreen({super.key, required this.onStartQuiz, required this.onNavigate});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Simulate brief load to show skeletons
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  static final List<Map<String, dynamic>> _categories = [
    {
      'id': 'computer-science',
      'title': 'Computer Science',
      'subtitle': '13 topics • 400+ questions',
      'icon': Icons.psychology,
      'color': const Color(0xFF2980B9),
      'gradientStart': const Color(0xFF2980B9),
      'gradientEnd': const Color(0xFF3498DB),
    },
    {
      'id': 'mathematics',
      'title': 'Mathematics',
      'subtitle': '10 topics • 330+ questions',
      'icon': Icons.calculate,
      'color': const Color(0xFF16A085),
      'gradientStart': const Color(0xFF16A085),
      'gradientEnd': const Color(0xFF1ABC9C),
    },
    {
      'id': 'general-knowledge',
      'title': 'General Knowledge',
      'subtitle': '3 topics • 120+ questions',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFF9B59B6),
      'gradientStart': const Color(0xFF9B59B6),
      'gradientEnd': const Color(0xFF8E44AD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Quizzes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a category to start learning',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              
              const SizedBox(height: 24),

              // Offline Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A085).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.wifi_off,
                      size: 16,
                      color: Color(0xFF16A085),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'All quizzes available offline',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF16A085),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Quiz Special Card
              _buildWeeklyQuizCard(context, isDark),

              const SizedBox(height: 24),

              // Category Cards
              ...List.generate(_categories.length, (index) {
                final category = _categories[index];
                if (_loading) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CategorySkeleton(isDark: isDark),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCategoryCard(
                    context,
                    category['id'] as String,
                    category['title'] as String,
                    category['subtitle'] as String,
                    category['icon'] as IconData,
                    category['gradientStart'] as Color,
                    category['gradientEnd'] as Color,
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Additional Options
              _buildOutlineButton(
                context,
                'Custom Quiz from My Notes',
                Icons.chevron_right,
                () => widget.onNavigate('notes'),
              ),
              
              // Removed Random Mixed Quiz (redundant feature)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color gradientStart,
    Color gradientEnd,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to sub topics; quiz starts from topic screen directly now.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubTopicsScreen(
                  category: id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background decorations
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyQuizCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/dailyQuiz');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🏆 Weekly Quiz',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Earn more XP with this week\'s special quiz!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E45) : const Color(0xFF34495E).withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? (isDark ? Colors.white : const Color(0xFF34495E)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  final bool isDark;
  const _CategorySkeleton({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222B45) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 32),
          // Simple animated shimmer using opacity loop via AnimatedOpacity could be added later.
        ],
      ),
    );
  }
}
