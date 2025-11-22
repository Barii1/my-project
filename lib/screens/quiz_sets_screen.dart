import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_question_screen.dart';

class QuizSetsScreen extends StatelessWidget {
  final QuizTopic topic;
  const QuizSetsScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sets = context.watch<QuizProvider>().setsFor(topic.id);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: Text(topic.title),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: sets.isEmpty
          ? Center(
              child: Text(
                'No quiz sets yet',
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: sets.length,
              itemBuilder: (c, i) {
                final set = sets[i];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizQuestionScreen(quizSet: set),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt_outlined, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(set.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
                              const SizedBox(height: 4),
                              Text('${set.timeLimitSec ~/ 60} min • ${context.read<QuizProvider>().questionsFor(set.id).length} Qs', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}