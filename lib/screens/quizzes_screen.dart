import 'package:flutter/material.dart';
import 'sub_topics_screen.dart';

typedef StartQuizCallback = void Function(String categoryId);
typedef NavigateCallback = void Function(String screen);

class QuizzesScreen extends StatelessWidget {
  final StartQuizCallback onStartQuiz;
  final NavigateCallback onNavigate;

  const QuizzesScreen({super.key, required this.onStartQuiz, required this.onNavigate});

  static final List<Map<String, dynamic>> _categories = [
    {
      'id': 'computer-science',
      'title': 'Computer Science',
      'subtitle': '15 topics • 450+ questions',
      'icon': Icons.psychology,
      'color': const Color(0xFF2980B9),
      'gradientStart': const Color(0xFF2980B9),
      'gradientEnd': const Color(0xFF3498DB),
    },
    {
      'id': 'mathematics',
      'title': 'Mathematics',
      'subtitle': '12 topics • 380+ questions',
      'icon': Icons.calculate,
      'color': const Color(0xFF16A085),
      'gradientStart': const Color(0xFF16A085),
      'gradientEnd': const Color(0xFF1ABC9C),
    },
    {
      'id': 'general-knowledge',
      'title': 'General Knowledge',
      'subtitle': 'Fun • Mixed topics',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFF9B59B6),
      'gradientStart': const Color(0xFF9B59B6),
      'gradientEnd': const Color(0xFF8E44AD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Quizzes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a category to start learning',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
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

              // Category Cards
              ...List.generate(_categories.length, (index) {
                final category = _categories[index];
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
                () => onNavigate('notes'),
              ),
              
              const SizedBox(height: 12),
              
              _buildOutlineButton(
                context,
                'Random Mixed Quiz',
                Icons.auto_awesome,
                () {
                  // Random mixed quiz functionality
                },
                iconColor: const Color(0xFF9B59B6),
              ),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubTopicsScreen(
                  category: id,
                  onSelectTopic: (topic) {
                    // Handle topic selection - you can navigate to quiz or show questions
                    Navigator.of(context).pop(); // Go back to quiz screen
                    onStartQuiz(topic['id'] as String);
                  },
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

  Widget _buildOutlineButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF34495E).withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? const Color(0xFF34495E),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
