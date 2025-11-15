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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                            Text('AI Tutor', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('Get instant help with any topic', style: Theme.of(context).textTheme.bodySmall),
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
                        errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.background),
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
                  Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                    onPressed: () => onNavigate('history'),
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                    child: const Text('View All'),
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

              Text('Select a Course', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
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
                    final primary = Theme.of(context).colorScheme.primary;
                    final cardColor = Theme.of(context).cardColor;

                    return Material(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onSelectCourse(name),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: primary.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(12)),
                                child: Icon(icon, color: primary, size: 26),
                              ),
                              const SizedBox(height: 12),
                              Text(name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
                            ],
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
    final primary = Theme.of(context).colorScheme.primary;
    final fg = Theme.of(context).textTheme.bodyLarge?.color;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onSelectCourse(course),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: primary.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.message, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic, style: TextStyle(color: fg)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(course, style: TextStyle(color: fg, fontSize: 12)),
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(color: fg, fontSize: 12)),
                        const SizedBox(width: 6),
                        Row(children: [Icon(Icons.access_time, size: 12, color: fg), const SizedBox(width: 4), Text(time, style: TextStyle(fontSize: 12, color: fg != null ? fg.withAlpha((0.7 * 255).round()) : null))] )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
