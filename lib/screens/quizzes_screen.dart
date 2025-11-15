import 'package:flutter/material.dart';
 
import 'quiz_taker_screen.dart';
import '../theme/app_theme.dart';

typedef StartQuizCallback = void Function(Map<String, dynamic> quiz);
typedef NavigateCallback = void Function(String screen);

class QuizzesScreen extends StatelessWidget {
  final StartQuizCallback onStartQuiz;
  final NavigateCallback onNavigate;

  const QuizzesScreen({super.key, required this.onStartQuiz, required this.onNavigate});

  static final List<Map<String, dynamic>> _quizzes = [
    {
      'id': 'ds-basics',
      'title': 'Data Structures Basics',
      'subject': 'CS',
      'questions': 15,
      'duration': 20,
      'difficulty': 'Easy',
      'icon': Icons.memory,
  'color': AppTheme.primary,
      'offline': true,
    },
    {
      'id': 'sorting-algo',
      'title': 'Sorting Algorithms',
      'subject': 'CS',
      'questions': 12,
      'duration': 15,
      'difficulty': 'Medium',
      'icon': Icons.memory,
  'color': AppTheme.primary,
      'offline': true,
    },
    {
      'id': 'calculus-1',
      'title': 'Calculus I - Derivatives',
      'subject': 'Math',
      'questions': 20,
      'duration': 25,
      'difficulty': 'Medium',
      'icon': Icons.calculate,
  'color': AppTheme.secondary,
      'offline': true,
    },
    {
      'id': 'integration',
      'title': 'Integration Techniques',
      'subject': 'Math',
      'questions': 18,
      'duration': 30,
      'difficulty': 'Hard',
      'icon': Icons.calculate,
  'color': AppTheme.secondary,
      'offline': false,
    },
    {
      'id': 'trees-graphs',
      'title': 'Trees & Graphs',
      'subject': 'CS',
      'questions': 16,
      'duration': 22,
      'difficulty': 'Hard',
      'icon': Icons.memory,
  'color': AppTheme.primary,
      'offline': true,
    },
    {
      'id': 'linear-algebra',
      'title': 'Linear Algebra Basics',
      'subject': 'Math',
      'questions': 14,
      'duration': 18,
      'difficulty': 'Easy',
      'icon': Icons.calculate,
  'color': AppTheme.secondary,
      'offline': false,
    },
  ];

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppTheme.secondary;
      case 'Medium':
        return AppTheme.warning;
      default:
        return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        title: Text('Quizzes', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () => onNavigate('notes'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // Create Custom Quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onNavigate('notes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Create Custom Quiz from Notes', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quiz list
            Expanded(
              child: ListView.separated(
                itemCount: _quizzes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final quiz = _quizzes[index];
                  final Color color = quiz['color'] as Color;
                  final IconData icon = quiz['icon'] as IconData;
                  final String difficulty = quiz['difficulty'] as String;
                  final diffColor = _difficultyColor(difficulty);

                  return Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        // Open the quiz taker screen and wait for completion.
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => QuizTakerScreen(
                            quiz: quiz,
                            onComplete: () {},
                          ),
                        ));

                        // Preserve existing callback behavior after the quiz route returns.
                        try {
                          onStartQuiz(quiz);
                        } catch (_) {}
                      },
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.15 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 26),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          quiz['title'] as String,
                                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      if (quiz['offline'] as bool)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.wifi_off, size: 14, color: Theme.of(context).colorScheme.onSurface),
                                              SizedBox(width: 6),
                                              Text('Offline', style: TextStyle(fontSize: 12, color: AppTheme.slate)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.adjust, size: 14, color: AppTheme.slate),
                                          const SizedBox(width: 6),
                                          Text('${quiz['questions']} questions', style: TextStyle(fontSize: 13, color: AppTheme.slate.withAlpha((0.9 * 255).round()))),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Text('•', style: TextStyle(color: AppTheme.slate.withAlpha((0.9 * 255).round()))),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: AppTheme.slate),
                                          const SizedBox(width: 6),
                                          Text('${quiz['duration']} min', style: TextStyle(fontSize: 13, color: AppTheme.slate.withAlpha((0.9 * 255).round()))),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha((0.15 * 255).round()),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(quiz['subject'] as String, style: TextStyle(color: color, fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: diffColor.withAlpha((0.15 * 255).round()),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(difficulty, style: TextStyle(color: diffColor, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
