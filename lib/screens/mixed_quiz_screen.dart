import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class MixedQuizScreen extends StatefulWidget {
  const MixedQuizScreen({super.key});

  @override
  State<MixedQuizScreen> createState() => _MixedQuizScreenState();
}

class _MixedQuizScreenState extends State<MixedQuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<QuizProvider>(context, listen: false);
    _questions = provider.mixedQuestions(max: 5);
  }

  void _select(QuizOption opt) {
    if (_finished) return;
    if (opt.correct) _score++;
    setState(() {
      if (_index == _questions.length - 1) {
        _finished = true;
      } else {
        _index++;
      }
    });
  }

  void _restart() {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    setState(() {
      _questions = provider.mixedQuestions(max: 5);
      _index = 0;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixed Quiz'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _finished ? _result(isDark) : _question(isDark),
      ),
    );
  }

  Widget _question(bool isDark) {
    final q = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_index + 1}/${_questions.length}', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Text(q.stem, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
        const SizedBox(height: 24),
        for (final opt in q.options) ...[
          _optTile(opt, isDark),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _optTile(QuizOption opt, bool isDark) {
    return InkWell(
      onTap: () => _select(opt),
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
              backgroundColor: const Color(0xFF9B59B6),
              child: Text(String.fromCharCode(65 + qIndex(opt)), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(opt.text, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF34495E), fontSize: 15))),
          ],
        ),
      ),
    );
  }

  int qIndex(QuizOption opt) => _questions[_index].options.indexOf(opt);

  Widget _result(bool isDark) {
    final percent = (_score / _questions.length * 100).round();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Score: $_score/${_questions.length} ($percent%)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF34495E))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _restart, child: const Text('Try Another Mix')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
          const SizedBox(height: 12),
          Text('Mixed quiz combines questions across sets.', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
