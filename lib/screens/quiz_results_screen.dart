import 'package:flutter/material.dart';
import 'quiz_review_screen.dart';
import '../providers/quiz_provider.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizSet quizSet;
  final List<QuizQuestion> questions;
  final Map<String, String> answers;
  const QuizResultsScreen({super.key, required this.quizSet, required this.questions, required this.answers});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int correct = 0;
    for (final q in questions) {
      final a = answers[q.id];
      if (a != null && q.options.firstWhere((o) => o.id == a).correct) correct++;
    }
    final percent = (correct / questions.length * 100).round();
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quizSet.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
            const SizedBox(height: 16),
            _StatTile(label: 'Score', value: '$correct / ${questions.length}'),
            _StatTile(label: 'Accuracy', value: '$percent%'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizReviewScreen(quizSet: quizSet, questions: questions, answers: answers),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB8A8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text('Review Answers'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : const Color(0xFF64748B)))),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
        ],
      ),
    );
  }
}