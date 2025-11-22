import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_sessions_provider.dart';

typedef CourseCallback = void Function(String course);
typedef NavigateCallback = void Function(String screen);

class AITutorScreen extends StatefulWidget {
  final CourseCallback onSelectCourse;
  final NavigateCallback onNavigate;

  const AITutorScreen({super.key, required this.onSelectCourse, required this.onNavigate});

  static const _courses = <Map<String, Object>>[
    {'id': 'data-structures', 'name': 'Data Structures', 'icon': Icons.storage, 'color': Color(0xFF3B82F6)},
    {'id': 'algorithms', 'name': 'Algorithms', 'icon': Icons.device_hub, 'color': Color(0xFF8B5CF6)},
    {'id': 'calculus', 'name': 'Calculus', 'icon': Icons.functions, 'color': Color(0xFF10B981)},
    {'id': 'linear-algebra', 'name': 'Linear Algebra', 'icon': Icons.calculate, 'color': Color(0xFFF59E0B)},
    {'id': 'discrete-math', 'name': 'Discrete Math', 'icon': Icons.code, 'color': Color(0xFFEC4899)},
    {'id': 'databases', 'name': 'Databases', 'icon': Icons.folder, 'color': Color(0xFF06B6D4)},
  ];

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  bool _showCta = true;
  String _search = '';
  static const _courses = AITutorScreen._courses; // bring static list into state context

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
              pinned: true,
              elevation: 0,
              title: Row(
                children: [
                  Text('AI Tutor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF34495E))),
                  const SizedBox(width: 6),
                  const Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'New Chat',
                  icon: const Icon(Icons.add_comment_outlined),
                  onPressed: () {
                    final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
                    final session = sessions.startSession('General');
                    Navigator.of(context).pushNamed('/ai-chat', arguments: {'course': 'General', 'sessionId': session.id});
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showCta) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20,18,20,16), // reduced height
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4DB8A8), Color(0xFF2F8B7E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DB8A8).withOpacity(0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text('Chat with your Ostaad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _showCta = false),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Ask questions, upload images or PDFs.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
                                  final session = sessions.startSession('General');
                                  Navigator.of(context).pushNamed('/ai-chat', arguments: {'course': 'General', 'sessionId': session.id});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2F8B7E),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                label: const Text('Start Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                    // Slim search bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222B45) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          hintText: 'Search subjects...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, size: 18),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Divider(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 18),
                    Text('Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
                    const SizedBox(height: 12),
                    Consumer<AiChatSessionsProvider>(
                      builder: (context, sessions, _) {
                        final list = sessions.sessions;
                        if (list.isEmpty) {
                          return _emptySessions(isDark);
                        }
                        return SizedBox(
                          height: 105,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            itemBuilder: (c, i) => _sessionChip(context, isDark, list[i]),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text('Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF34495E))),
                    const SizedBox(height: 16),
                    // Filter subjects by search query
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.05,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: _courses.where((c) => _search.isEmpty || (c['name'] as String).toLowerCase().contains(_search.toLowerCase())).length,
                      itemBuilder: (context, index) {
                        final filtered = _courses.where((c) => _search.isEmpty || (c['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();
                        final item = filtered[index];
                        return _subjectCard(context, item);
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectCard(BuildContext context, Map<String,Object> item) {
    final icon = item['icon'] as IconData;
    final name = item['name'] as String;
    final color = item['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222B45) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).pushNamed('/topicOverview', arguments: {'title': name, 'courseId': name}),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E)), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.flash_on, size: 16, color: color.withValues(alpha: 1.0)),
                  const SizedBox(width: 4),
                  Text('Explore', style: TextStyle(fontSize: 12, color: color)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptySessions(bool isDark) {
    return Container(
      height: 90,
      alignment: Alignment.centerLeft,
      child: Text('No sessions yet. Start a chat!', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B))),
    );
  }

  Widget _sessionChip(BuildContext context, bool isDark, ChatSession session) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222B45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed('/ai-chat', arguments: {'course': session.subject, 'sessionId': session.id}),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF4DB8A8)),
              const SizedBox(height: 10),
              Text(session.subject, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Expanded(
                child: Text(session.lastMessage, style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : const Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Text('Resume', style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }
}
