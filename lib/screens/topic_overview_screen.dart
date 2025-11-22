import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_sessions_provider.dart';

class TopicOverviewScreen extends StatelessWidget {
  final String title;
  final String courseId;

  const TopicOverviewScreen({super.key, required this.title, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _sectionHeader('Quick Prompts', isDark),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickPrompts.map((p) => _promptChip(context, p, isDark)).toList(),
          ),
          const SizedBox(height: 28),
          _sectionHeader('Actions', isDark),
          _actionTile(context, Icons.chat, 'Open Chat', 'Discuss $title concepts', () {
            final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
            final session = sessions.startSession(title);
            Navigator.of(context).pushNamed('/ai-chat', arguments: {'course': title, 'sessionId': session.id});
          }, isDark),
          _actionTile(context, Icons.quiz, 'Quick Quiz', '5 question practice set', () {
            Navigator.of(context).pushNamed('/quizQuick', arguments: {'topic': title});
          }, isDark),
          _actionTile(context, Icons.book_outlined, 'Summary', 'Condensed overview', () {}, isDark),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
      );

  Widget _promptChip(BuildContext context, String prompt, bool isDark) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222B45) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
        ),
        child: Text(prompt, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF34495E))),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222B45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A324F) : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4DB8A8)),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }

  List<String> get _quickPrompts => [
        'Explain basics',
        'Give analogy',
        'Common mistakes',
        'Practice ideas',
        'Advanced tip',
      ];
}
