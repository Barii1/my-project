import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = const [
      'Arrays & Strings',
      'Linked Lists',
      'Trees',
      'Graphs',
      'Dynamic Programming',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final topic = topics[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Practice questions and mini tests'),
                trailing: SizedBox(
                  width: 88,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/dailyQuiz'),
                    child: const Text('Start'),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: topics.length,
        ),
      ),
    );
  }
}
