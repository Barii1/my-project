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
      body: Column(
        children: [
          // Header styled like SubTopicsScreen
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AI Tutor',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF34495E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('✨', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Your personal learning assistant',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Chat History',
                      icon: Icon(
                        Icons.history,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/history');
                      },
                    ),
                    IconButton(
                      tooltip: 'My Notes',
                      icon: Icon(
                        Icons.note_outlined,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/notes');
                      },
                    ),
                    IconButton(
                      tooltip: 'New Chat',
                      icon: Icon(
                        Icons.add_comment_outlined,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      onPressed: () {
                        final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
                        final session = sessions.startSession('General');
                        Navigator.of(context).pushNamed('/ai-chat', arguments: {'course': 'General', 'sessionId': session.id});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    if (_showCta) ...[
                      // Styled like SubTopics screen card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF16213E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2A2E45) : const Color(0xFF34495E).withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/chat');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4DB8A8).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF4DB8A8),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Chat with your Ostaad',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : const Color(0xFF34495E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ask questions, upload images or PDFs',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => _showCta = false),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.close, size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                    const SizedBox(height: 24),
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
}
