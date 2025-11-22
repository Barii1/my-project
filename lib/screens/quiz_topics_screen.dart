import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_sets_screen.dart';

class QuizTopicsScreen extends StatelessWidget {
  final QuizCategory category;
  const QuizTopicsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = context.watch<QuizProvider>().topicsFor(category.id);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: topics.length,
        itemBuilder: (c, i) {
          final topic = topics[i];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizSetsScreen(topic: topic),
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
                  Icon(Icons.topic_outlined, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(topic.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
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