import 'package:flutter/material.dart';

typedef CourseCallback = void Function(String course);

typedef NavigateCallback = void Function(String screen);

class AITutorScreen extends StatelessWidget {
  final CourseCallback onSelectCourse;
  final NavigateCallback onNavigate;

  const AITutorScreen({super.key, required this.onSelectCourse, required this.onNavigate});

  static const _courses = <Map<String, Object>>[
    {'id': 'data-structures', 'name': 'Data Structures', 'icon': Icons.storage},
    {'id': 'algorithms', 'name': 'Algorithms', 'icon': Icons.device_hub},
    {'id': 'calculus', 'name': 'Calculus', 'icon': Icons.functions},
    {'id': 'linear-algebra', 'name': 'Linear Algebra', 'icon': Icons.calculate},
    {'id': 'discrete-math', 'name': 'Discrete Math', 'icon': Icons.code},
    {'id': 'computer-architecture', 'name': 'Architecture', 'icon': Icons.memory},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Tutor', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                            const SizedBox(height: 6),
                            const Text('Get instant help with any topic', style: TextStyle(fontSize: 14, color: Color(0xFF757575), fontFamily: 'Poppins')),
                          ],
                    ),
                  ),
                  // decorative image
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1526378724497-7f2d6f0d3f5f?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&s=placeholder',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Recent chats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Chats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                  TextButton(
                    onPressed: () => onNavigate('history'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF00A8A8)),
                    child: const Text('View All', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Column(
                children: [
                  _recentChatTile(context, 'Data Structures', 'Binary Search Trees', '2h ago'),
                  const SizedBox(height: 8),
                  _recentChatTile(context, 'Calculus', 'Integration by Parts', 'Yesterday'),
                ],
              ),

              const SizedBox(height: 18),

              const Text('Select a Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
              const SizedBox(height: 12),

              // Course grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.25, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final item = _courses[index];
                    final icon = item['icon'] as IconData;
                    final name = item['name'] as String;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: () => onSelectCourse(name),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(color: const Color(0xFFE6F7F7), borderRadius: BorderRadius.circular(16)),
                                  child: Icon(icon, color: const Color(0xFF00A3A3), size: 28),
                                ),
                                const SizedBox(height: 12),
                                Text(name, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentChatTile(BuildContext context, String course, String topic, String time) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE6ED), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onSelectCourse(course),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFE6F7F7), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.message, color: Color(0xFF00A8A8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(course, style: const TextStyle(color: Color(0xFF757575), fontSize: 12, fontFamily: 'Poppins')),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: Color(0xFF757575), fontSize: 12)),
                          const SizedBox(width: 6),
                          Row(children: [const Icon(Icons.access_time, size: 12, color: Color(0xFF757575)), const SizedBox(width: 4), Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF999999), fontFamily: 'Poppins'))])
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
