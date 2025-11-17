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
      appBar: AppBar(title: const Text('Daily Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_index + 1} of ${_questions.length}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q['q'] as String, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...List.generate(options.length, (i) {
                      final opt = options[i];
                      final selected = _selected == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: InkWell(
                          onTap: () => _select(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Radio<int>(value: i, groupValue: _selected, onChanged: (int? v) => _select(v!)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(opt)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selected == null ? null : _submit,
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    )
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
