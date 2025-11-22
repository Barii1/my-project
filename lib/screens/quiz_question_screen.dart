import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_results_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final QuizSet quizSet;
  const QuizQuestionScreen({super.key, required this.quizSet});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _index = 0;
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = context.watch<QuizProvider>().questionsFor(widget.quizSet.id);
    final q = questions[_index];
    final selected = _answers[q.id];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: Text(widget.quizSet.title),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_index + 1}/${questions.length}', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
              ),
              child: Text(q.stem, style: TextStyle(fontSize: 16, height: 1.5, color: isDark ? Colors.white : const Color(0xFF34495E))),
            ),
            const SizedBox(height: 20),
            ...q.options.map((o) => _OptionTile(
                  option: o,
                  selected: selected == o.id,
                  onTap: () => setState(() => _answers[q.id] = o.id),
                  isDark: isDark,
                )),
            const Spacer(),
            Row(
              children: [
                if (_index > 0)
                  TextButton(
                    onPressed: () => setState(() => _index--),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () {
                          if (_index < questions.length - 1) {
                            setState(() => _index++);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizResultsScreen(
                                  quizSet: widget.quizSet,
                                  questions: questions,
                                  answers: _answers,
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB8A8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: Text(_index < questions.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _OptionTile({required this.option, required this.selected, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4DB8A8)
              : (isDark ? const Color(0xFF16213E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF4DB8A8)
                : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          option.text,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.white : const Color(0xFF34495E)),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}