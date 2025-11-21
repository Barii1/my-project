import 'package:flutter/material.dart';

typedef CourseCallback = void Function(String course);
typedef NavigateCallback = void Function(String screen);

class AITutorScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Row(
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '✨',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your personal learning assistant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Start Card
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DB8A8).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ask me anything!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Start a conversation',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Chats Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Chats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34495E),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigate('history'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF3DA89A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _recentChatTile(
                  context,
                  'Binary Search Trees',
                  'Data Structures',
                  '2h ago',
                  Icons.storage,
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 10),
                _recentChatTile(
                  context,
                  'Integration by Parts',
                  'Calculus',
                  'Yesterday',
                  Icons.functions,
                  const Color(0xFF10B981),
                ),

                const SizedBox(height: 32),

                // Subjects Grid
                const Text(
                  'Choose a Subject',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34495E),
                  ),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final item = _courses[index];
                    final icon = item['icon'] as IconData;
                    final name = item['name'] as String;
                    final color = item['color'] as Color;

                    return _buildCourseCard(context, icon, name, color);
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, IconData icon, String name, Color color) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelectCourse(name),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF34495E),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentChatTile(
    BuildContext context,
    String topic,
    String course,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelectCourse(course),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF34495E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            course,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD1D5DB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
