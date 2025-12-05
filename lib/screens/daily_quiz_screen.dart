import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../services/quiz_attempt_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/xp_service.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  final List<Map<String, Object>> _questions = [
    {
      'q': 'What is the time complexity of binary search?',
      'options': ['O(n)', 'O(log n)', 'O(n log n)', 'O(1)'],
      'answer': 1,
      'subject': 'Algorithms',
    },
    {
      'q': 'Which data structure uses FIFO?',
      'options': ['Stack', 'Queue', 'Tree', 'Graph'],
      'answer': 1,
      'subject': 'Data Structures',
    },
    {
      'q': 'Which keyword is used to define a constant in Dart?',
      'options': ['var', 'final', 'const', 'let'],
      'answer': 2,
      'subject': 'Computer Science',
    },
  ];

  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  void _select(int i) {
    if (!_answered) {
      setState(() => _selected = i);
    }
  }

  void _submit() {
    if (_selected == null) return;
    
    final correct = _questions[_index]['answer'] as int;
    final isCorrect = _selected == correct;
    
    if (isCorrect) {
      _score += 1;
    }
    
    setState(() => _answered = true);
    
    // Show feedback and move to next after delay
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      
      if (_index < _questions.length - 1) {
        setState(() {
          _selected = null;
          _answered = false;
          _index += 1;
        });
      } else {
        // Quiz complete - handle all async operations first
        
        // Update stats
        final stats = Provider.of<StatsProvider>(context, listen: false);
        
        // Track score per subject
        final Map<String, List<int>> subjectScores = {};
        for (int i = 0; i < _questions.length; i++) {
          final subject = _questions[i]['subject'] as String;
          final answer = _questions[i]['answer'] as int;
          final userAnswer = i == _index ? _selected : null;
          final isCorrect = (i < _index) || (i == _index && userAnswer == answer);
          
          if (!subjectScores.containsKey(subject)) {
            subjectScores[subject] = [0, 0]; // [correct, total]
          }
          subjectScores[subject]![1] += 1; // total questions
          if (isCorrect) {
            subjectScores[subject]![0] += 1; // correct answers
          }
        }
        
        // Update each subject's accuracy (XP awarded by backend)
        subjectScores.forEach((subject, scores) {
          stats.completeQuiz(subject, scores[0], scores[1]);
        });
        
        final percentage = (_score / _questions.length * 100);
        final xpEarned = percentage.toInt();
        
        // Persist quiz attempt to backend (awards XP server-side)
        try {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          QuizAttemptService.recordAttempt(
            userId: userId ?? 'anonymous',
            subject: 'Weekly Quiz',
            correct: _score,
            total: _questions.length,
            xpEarned: xpEarned,
          );
        } catch (_) {}

        // Award XP locally (Firestore) so Total XP updates immediately
        try {
          await XpService().awardXpForQuizCompletion(
            questionCount: _questions.length,
            scorePercent: percentage,
            noSkippedQuestions: true,
            subjectId: 'WeeklyQuiz',
          );
        } catch (e) {
          debugPrint('XP quiz award failed: $e');
        }
        
        // Increment daily goal counter
        try {
          final prefs = await SharedPreferences.getInstance();
          final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
          final currentCount = prefs.getInt('daily_quiz_count_$uid') ?? 0;
          await prefs.setInt('daily_quiz_count_$uid', currentCount + 1);
        } catch (_) {
          // Best-effort: ignore failures
        }
        
        // Show result dialog
        if (!mounted) return;
        
        showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: Row(
              children: [
                Text(percentage >= 70 ? '🎉' : '💪'),
                const SizedBox(width: 8),
                const Text('Quiz Complete!'),
              ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You scored $_score / ${_questions.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('${percentage.toInt()}% accuracy'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DB8A8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '+$xpEarned XP Earned!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4DB8A8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(c).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB8A8),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        
        // Reset quiz state
        setState(() {
          _index = 0;
          _score = 0;
          _selected = null;
          _answered = false;
        });
      }
    });
  }

  Color _getOptionColor(int index) {
    if (!_answered) {
      return _selected == index
          ? const Color(0xFF4DB8A8).withOpacity(0.2)
          : Colors.transparent;
    }
    
    final correct = _questions[_index]['answer'] as int;
    if (index == correct) {
      return Colors.green.withOpacity(0.2);
    }
    if (index == _selected && _selected != correct) {
      return Colors.red.withOpacity(0.2);
    }
    return Colors.transparent;
  }
  
  IconData? _getOptionIcon(int index) {
    if (!_answered) return null;
    
    final correct = _questions[_index]['answer'] as int;
    if (index == correct) {
      return Icons.check_circle;
    }
    if (index == _selected && _selected != correct) {
      return Icons.cancel;
    }
    return null;
  }
  
  Color? _getOptionIconColor(int index) {
    if (!_answered) return null;
    
    final correct = _questions[_index]['answer'] as int;
    if (index == correct) {
      return Colors.green;
    }
    if (index == _selected && _selected != correct) {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final options = (q['options'] as List<String>);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Weekly Quiz',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: [
                Text(
                  'Question ${_index + 1} of ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3DA89A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Linear progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                backgroundColor: const Color(0xFFE5E7EB),
                color: const Color(0xFF3DA89A),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q['q'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(options.length, (i) {
                      final opt = options[i];
                      final selected = _selected == i;
                      final bgColor = _getOptionColor(i);
                      final icon = _getOptionIcon(i);
                      final iconColor = _getOptionIconColor(i);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _select(i),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor != Colors.transparent 
                                    ? bgColor
                                    : (selected
                                        ? const Color(0xFF3DA89A).withOpacity(0.1)
                                        : const Color(0xFFFEF7FA)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: iconColor ?? (selected
                                      ? const Color(0xFF3DA89A)
                                      : const Color(0xFFFFE6ED)),
                                  width: selected || icon != null ? 2 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: iconColor ?? (selected
                                            ? const Color(0xFF3DA89A)
                                            : const Color(0xFFE5E7EB)),
                                        width: 2,
                                      ),
                                      color: selected || icon != null
                                          ? (iconColor ?? const Color(0xFF3DA89A))
                                          : Colors.transparent,
                                    ),
                                    child: icon != null
                                        ? Icon(icon, size: 14, color: Colors.white)
                                        : (selected
                                            ? const Icon(
                                                Icons.circle,
                                                size: 12,
                                                color: Colors.white,
                                              )
                                            : null),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: selected || icon != null ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (icon != null)
                                    Icon(icon, color: iconColor, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _selected == null
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                        color: _selected == null ? const Color(0xFFE5E7EB) : null,
                        boxShadow: _selected == null
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF4DB8A8).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selected == null ? null : _submit,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Submit Answer',
                                style: TextStyle(
                                  color: _selected == null
                                      ? const Color(0xFF94A3B8)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
