import 'package:flutter/material.dart';

class QuickQuizScreen extends StatefulWidget {
  final String topic;
  const QuickQuizScreen({super.key, required this.topic});

  @override
  State<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends State<QuickQuizScreen> {
  final List<_QuickQuestion> _questions = [];
  int _current = 0;
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions.addAll(_generate(widget.topic));
  }

  List<_QuickQuestion> _generate(String topic) {
    return [
      _QuickQuestion('Core idea of $topic?', ['Definition', 'Random', 'Unrelated', 'Skip'], 0),
      _QuickQuestion('One common mistake?', ['Wrong pattern', 'Perfect recall', 'Always success', 'Unlimited time'], 0),
      _QuickQuestion('Best first step?', ['Understand problem', 'Guess', 'Ignore', 'Sleep'], 0),
      _QuickQuestion('Why practice matters?', ['Retention', 'Decoration', 'Luck', 'None'], 0),
      _QuickQuestion('Advanced aspect?', ['Optimization', 'Avoidance', 'Deletion', 'Magic'], 0),
    ];
  }

  void _select(int index) {
    if (_finished) return;
    final q = _questions[_current];
    if (index == q.correct) _score++;
    setState(() {
      if (_current == _questions.length - 1) {
        _finished = true;
      } else {
        _current++;
      }
    });
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Quiz: ${widget.topic}'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _finished ? _buildResult(isDark) : _buildQuestion(isDark),
      ),
    );
  }

  Widget _buildQuestion(bool isDark) {
    final q = _questions[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_current + 1}/${_questions.length}', style: TextStyle(color: isDark ? Colors.white70.withValues(alpha: 0.7) : const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Text(q.prompt, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
        const SizedBox(height: 24),
        for (int i = 0; i < q.options.length; i++) ...[
          _optionTile(q.options[i], i, isDark),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _optionTile(String text, int index, bool isDark) {
    return InkWell(
      onTap: () => _select(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222B45) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF4DB8A8),
              child: Text(String.fromCharCode(65 + index), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF34495E), fontSize: 15))),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final percent = (_score / _questions.length * 100).round();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Score: $_score/${_questions.length} ($percent%)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF34495E))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _restart, child: const Text('Retake')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.of(context).pushNamed('/quiz'), child: const Text('Full Quiz')),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Start an AI chat session about mistakes
              final subject = widget.topic;
              // Navigate assuming route expects args
              Navigator.of(context).pushNamed('/topicOverview', arguments: {'title': subject, 'courseId': subject});
            },
            child: const Text('Ask AI About Mistakes'),
          ),
          const SizedBox(height: 12),
          Text('Great quick check! Try full quiz for deeper practice.', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _QuickQuestion {
  final String prompt;
  final List<String> options;
  final int correct;
  _QuickQuestion(this.prompt, this.options, this.correct);
}
