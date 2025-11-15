import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
 
typedef VoidCallbackNoArgs = void Function();

class QuizTakerScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final VoidCallbackNoArgs onComplete;

  const QuizTakerScreen({super.key, required this.quiz, required this.onComplete});

  @override
  State<QuizTakerScreen> createState() => _QuizTakerScreenState();
}

class _QuizTakerScreenState extends State<QuizTakerScreen> {
  // Sample questions (mirrors the provided sampleQuestions)
  final List<Map<String, dynamic>> _questions = const [
    {
      'question': 'What is the time complexity of binary search?',
      'options': ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
      'correct': 1,
    },
    {
      'question': 'Which data structure uses LIFO principle?',
      'options': ['Queue', 'Stack', 'Array', 'Linked List'],
      'correct': 1,
    },
    {
      'question': 'What is the derivative of x²?',
      'options': ['x', '2x', 'x²', '2x²'],
      'correct': 1,
    },
  ];

  int _currentQuestion = 0;
  int? _selectedAnswer;
  late List<int?> _answers;
  late int _timeLeftSeconds;
  Timer? _timer;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(_questions.length, null);
    // Be defensive parsing duration: allow int, double, or string input.
    final rawDuration = widget.quiz['duration'];
    int durationMinutes = 5;
    if (rawDuration is int) {
      durationMinutes = rawDuration;
    } else if (rawDuration is double) {
      durationMinutes = rawDuration.toInt();
    } else if (rawDuration is String) {
      durationMinutes = int.tryParse(rawDuration) ?? 5;
    }
    _timeLeftSeconds = durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_showResults) return;
      setState(() {
        if (_timeLeftSeconds <= 1) {
          _timeLeftSeconds = 0;
          _finish();
        } else {
          _timeLeftSeconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _answers[_currentQuestion] = index;
    });
  }

  void _next() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = _answers[_currentQuestion];
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    setState(() {
      _showResults = true;
    });
  }

  int _calculateScore() {
    var correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] != null && _answers[i] == _questions[i]['correct']) correct++;
    }
    return correct;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = ((_currentQuestion + 1) / _questions.length) * 100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: Theme.of(context).appBarTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Close the quiz screen and then call the optional onComplete handler.
                          Navigator.of(context).maybePop();
                          try {
                            widget.onComplete();
                          } catch (_) {}
                        },
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text(_formatTime(_timeLeftSeconds), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Progress
              Container(
                color: Theme.of(context).appBarTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Question ${_currentQuestion + 1} of ${_questions.length}', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                        Text('${progress.round()}%', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progress / 100.0,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Question area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          question['question'] as String,
                          key: ValueKey(_currentQuestion),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF34495E)),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Column(
                        children: List.generate((question['options'] as List).length, (index) {
                          final optionText = (question['options'] as List)[index] as String;
                          final selected = _selectedAnswer == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: selected ? Theme.of(context).colorScheme.primary.withAlpha(30) : Theme.of(context).cardColor,
                                side: BorderSide(color: selected ? Theme.of(context).colorScheme.primary : const Color(0xFF34495E).withAlpha(25)),
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _selectAnswer(index),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                      border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : const Color(0xFF34495E).withAlpha(30)),
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(optionText, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                color: Theme.of(context).appBarTheme.backgroundColor,
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer == null ? null : _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_currentQuestion < _questions.length - 1 ? 'Next Question' : 'Finish Quiz'),
                  ),
                ),
              ),
            ],
          ),

          // Results overlay
          if (_showResults) Positioned.fill(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final score = _calculateScore();
    final percentage = ((_questions.isEmpty) ? 0 : ((score / _questions.length) * 100)).round();

    return Material(
      color: Colors.black54,
          child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.appGradient,
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text('Quiz Complete!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 8),
                Text('$percentage%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Text('$score out of ${_questions.length} correct', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                const SizedBox(height: 16),

                Column(
                  children: List.generate(_questions.length, (i) {
                    final user = _answers[i];
                    final correct = _questions[i]['correct'] as int;
                    final isCorrect = user != null && user == correct;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Question ${i + 1}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                      try {
                        widget.onComplete();
                      } catch (_) {}
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Back to Quizzes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
