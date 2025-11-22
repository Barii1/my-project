import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';

class QuizReviewScreen extends StatelessWidget {
  final QuizSet quizSet;
  final List<QuizQuestion> questions;
  final Map<String, String> answers;
  const QuizReviewScreen({super.key, required this.quizSet, required this.questions, required this.answers});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Review'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: questions.length,
        itemBuilder: (c, i) {
          final q = questions[i];
          final chosen = answers[q.id];
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.stem, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
                const SizedBox(height: 12),
                ...q.options.map((o) {
                  final correct = o.correct;
                  final selected = o.id == chosen;
                  final bg = selected
                      ? (correct ? const Color(0xFF4DB8A8) : const Color(0xFFEF4444))
                      : (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6));
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          correct ? Icons.check_circle : Icons.circle_outlined,
                          size: 18,
                          color: correct ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            o.text,
                            style: TextStyle(
                              color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF34495E)),
                            ),
                          ),
                        ),
                        if (selected && !correct)
                          const Icon(Icons.close, color: Colors.white, size: 18),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Text('Explanation', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
                const SizedBox(height: 4),
                Text(q.explanation, style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
              ],
            ),
          );
        },
      ),
    );
  }
}