import 'package:flutter/material.dart';
 
class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Recent Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(question.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(question.subject, style: const TextStyle(fontSize: 12)),
                            const Spacer(),
                            Text(question.time, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(question.text, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildActionChip(context, Icons.chat_bubble_outline, '${question.replies} replies'),
                            const SizedBox(width: 8),
                            _buildActionChip(context, Icons.thumb_up_outlined, '${question.likes} likes'),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Replies coming soon')),
                                );
                              },
                              icon: const Icon(Icons.reply, size: 18),
                              label: const Text('Reply'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ask a question coming soon')),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}

class Question {
  final String subject;
  final IconData icon;
  final String text;
  final String time;
  final int replies;
  final int likes;

  const Question({
    required this.subject,
    required this.icon,
    required this.text,
    required this.time,
    required this.replies,
    required this.likes,
  });
}

final _questions = [
  Question(
    subject: 'Computer Science',
    icon: Icons.computer,
    text: 'Can someone explain the concept of recursion in programming and provide a simple example?',
    time: '2h ago',
    replies: 5,
    likes: 12,
  ),
  Question(
    subject: 'Mathematics',
    icon: Icons.calculate,
    text: 'How do you solve quadratic equations using the quadratic formula? Need help understanding the steps.',
    time: '4h ago',
    replies: 8,
    likes: 15,
  ),
  Question(
    subject: 'Physics',
    icon: Icons.science,
    text: 'What\'s the difference between velocity and acceleration? Looking for a clear explanation.',
    time: '6h ago',
    replies: 6,
    likes: 9,
  ),
  Question(
    subject: 'Computer Science',
    icon: Icons.computer,
    text: 'How does a binary search algorithm work? Need help with time complexity analysis.',
    time: '1d ago',
    replies: 12,
    likes: 24,
  ),
];