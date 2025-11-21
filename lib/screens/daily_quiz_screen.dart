import 'package:flutter/material.dart';

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
    },
    {
      'q': 'Which data structure uses FIFO?',
      'options': ['Stack', 'Queue', 'Tree', 'Graph'],
      'answer': 1,
    },
    {
      'q': 'Which keyword is used to define a constant in Dart?',
      'options': ['var', 'final', 'const', 'let'],
      'answer': 2,
    },
  ];

  int _index = 0;
  int _score = 0;
  int? _selected;

  void _select(int i) {
    setState(() => _selected = i);
  }

  void _submit() {
    final correct = _questions[_index]['answer'] as int;
    if (_selected != null && _selected == correct) {
      _score += 1;
    }
    setState(() {
      _selected = null;
      if (_index < _questions.length - 1) {
        _index += 1;
      } else {
        // show result
        showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Quiz complete'),
            content: Text('You scored $_score / ${_questions.length}'),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Close')),
              ElevatedButton(onPressed: () { Navigator.of(c).pop(); Navigator.of(context).pop(); }, child: const Text('Done')),
            ],
          ),
        );
        _index = 0;
        _score = 0;
      }
    });
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
          'Daily Quiz',
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _select(i),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF3DA89A).withOpacity(0.1)
                                    : const Color(0xFFFEF7FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF3DA89A)
                                      : const Color(0xFFFFE6ED),
                                  width: selected ? 2 : 1,
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
                                        color: selected
                                            ? const Color(0xFF3DA89A)
                                            : const Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                      color: selected
                                          ? const Color(0xFF3DA89A)
                                          : Colors.transparent,
                                    ),
                                    child: selected
                                        ? const Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
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
