import 'package:flutter/material.dart';

typedef SelectTopicCallback = void Function(Map<String, dynamic> topic);

class SubTopicsScreen extends StatelessWidget {
  final String category;
  final SelectTopicCallback onSelectTopic;

  const SubTopicsScreen({
    super.key,
    required this.category,
    required this.onSelectTopic,
  });

  static final List<Map<String, dynamic>> _csTopics = [
    {
      'id': 'arrays-strings',
      'name': 'Arrays & Strings',
      'icon': Icons.layers,
      'color': const Color(0xFF2980B9),
      'questions': 35,
    },
    {
      'id': 'linked-lists',
      'name': 'Linked Lists',
      'icon': Icons.link,
      'color': const Color(0xFF3498DB),
      'questions': 28,
    },
    {
      'id': 'stacks-queues',
      'name': 'Stacks & Queues',
      'icon': Icons.layers_outlined,
      'color': const Color(0xFF5DADE2),
      'questions': 25,
    },
    {
      'id': 'trees-bst',
      'name': 'Trees & BST',
      'icon': Icons.account_tree,
      'color': const Color(0xFF16A085),
      'questions': 42,
    },
    {
      'id': 'graphs',
      'name': 'Graphs',
      'icon': Icons.hub,
      'color': const Color(0xFF1ABC9C),
      'questions': 38,
    },
    {
      'id': 'sorting',
      'name': 'Sorting Algorithms',
      'icon': Icons.swap_vert,
      'color': const Color(0xFFE67E22),
      'questions': 30,
    },
    {
      'id': 'searching',
      'name': 'Searching',
      'icon': Icons.search,
      'color': const Color(0xFFE74C3C),
      'questions': 22,
    },
    {
      'id': 'recursion',
      'name': 'Recursion',
      'icon': Icons.repeat,
      'color': const Color(0xFF9B59B6),
      'questions': 32,
    },
    {
      'id': 'dynamic-programming',
      'name': 'Dynamic Programming',
      'icon': Icons.flash_on,
      'color': const Color(0xFFF39C12),
      'questions': 40,
    },
    {
      'id': 'oop',
      'name': 'OOP Concepts',
      'icon': Icons.code,
      'color': const Color(0xFF8E44AD),
      'questions': 28,
    },
    {
      'id': 'databases',
      'name': 'Databases & SQL',
      'icon': Icons.storage,
      'color': const Color(0xFF27AE60),
      'questions': 35,
    },
    {
      'id': 'operating-systems',
      'name': 'Operating Systems',
      'icon': Icons.computer,
      'color': const Color(0xFF34495E),
      'questions': 30,
    },
    {
      'id': 'computer-networks',
      'name': 'Computer Networks',
      'icon': Icons.wifi,
      'color': const Color(0xFF2C3E50),
      'questions': 33,
    },
  ];

  static final List<Map<String, dynamic>> _mathTopics = [
    {
      'id': 'algebra',
      'name': 'Algebra',
      'icon': Icons.functions,
      'color': const Color(0xFF16A085),
      'questions': 40,
    },
    {
      'id': 'linear-algebra',
      'name': 'Linear Algebra',
      'icon': Icons.grid_4x4,
      'color': const Color(0xFF1ABC9C),
      'questions': 38,
    },
    {
      'id': 'calculus-1',
      'name': 'Calculus I',
      'icon': Icons.show_chart,
      'color': const Color(0xFF2980B9),
      'questions': 45,
    },
    {
      'id': 'calculus-2',
      'name': 'Calculus II',
      'icon': Icons.functions,
      'color': const Color(0xFF3498DB),
      'questions': 42,
    },
    {
      'id': 'discrete-math',
      'name': 'Discrete Math',
      'icon': Icons.grain,
      'color': const Color(0xFF9B59B6),
      'questions': 35,
    },
    {
      'id': 'probability',
      'name': 'Probability',
      'icon': Icons.bar_chart,
      'color': const Color(0xFFE67E22),
      'questions': 32,
    },
    {
      'id': 'statistics',
      'name': 'Statistics',
      'icon': Icons.analytics,
      'color': const Color(0xFFE74C3C),
      'questions': 30,
    },
    {
      'id': 'geometry',
      'name': 'Geometry',
      'icon': Icons.category,
      'color': const Color(0xFFF39C12),
      'questions': 28,
    },
    {
      'id': 'trigonometry',
      'name': 'Trigonometry',
      'icon': Icons.change_history,
      'color': const Color(0xFF8E44AD),
      'questions': 25,
    },
    {
      'id': 'number-theory',
      'name': 'Number Theory',
      'icon': Icons.tag,
      'color': const Color(0xFF27AE60),
      'questions': 22,
    },
  ];

  static final List<Map<String, dynamic>> _generalTopics = [
    {
      'id': 'general-science',
      'name': 'General Science',
      'icon': Icons.science,
      'color': const Color(0xFF9B59B6),
      'questions': 50,
    },
    {
      'id': 'tech-trivia',
      'name': 'Tech Trivia',
      'icon': Icons.devices,
      'color': const Color(0xFF3498DB),
      'questions': 40,
    },
    {
      'id': 'math-puzzles',
      'name': 'Math Puzzles',
      'icon': Icons.all_inclusive,
      'color': const Color(0xFF16A085),
      'questions': 35,
    },
  ];

  Map<String, dynamic> _getCategoryData() {
    switch (category) {
      case 'computer-science':
        return {
          'title': 'Computer Science',
          'topics': _csTopics,
          'color': const Color(0xFF2980B9),
        };
      case 'mathematics':
        return {
          'title': 'Mathematics',
          'topics': _mathTopics,
          'color': const Color(0xFF16A085),
        };
      case 'general-knowledge':
        return {
          'title': 'General Knowledge',
          'topics': _generalTopics,
          'color': const Color(0xFF9B59B6),
        };
      default:
        return {
          'title': 'Topics',
          'topics': <Map<String, dynamic>>[],
          'color': const Color(0xFF34495E),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();
    final String title = categoryData['title'] as String;
    final List<Map<String, dynamic>> topics =
        categoryData['topics'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF34495E).withOpacity(0.1),
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
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF34495E),
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF34495E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select a topic to start',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Topics Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return _buildTopicCard(context, topic, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, Map<String, dynamic> topic, int index) {
    final IconData icon = topic['icon'] as IconData;
    final Color color = topic['color'] as Color;
    final String name = topic['name'] as String;
    final int questions = topic['questions'] as int;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF34495E).withOpacity(0.1),
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
            onTap: () => onSelectTopic(topic),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Topic Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34495E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Questions Count
                  Text(
                    '$questions questions',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
