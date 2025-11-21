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
      backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Practice', style: TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final topic = topics[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'Poppins', color: Color(0xFF1A1A1A))),
                subtitle: const Text('Practice questions and mini tests', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                trailing: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00E5C2), Color(0xFF00A8A8)]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/dailyQuiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
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
