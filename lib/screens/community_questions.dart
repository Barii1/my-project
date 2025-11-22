import 'package:flutter/material.dart';
import 'question_detail.dart';

class CommunityQuestionsScreen extends StatefulWidget {
  const CommunityQuestionsScreen({super.key});

  @override
  State<CommunityQuestionsScreen> createState() => _CommunityQuestionsScreenState();
}

class _CommunityQuestionsScreenState extends State<CommunityQuestionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Unanswered', 'Popular', 'Recent'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        shadowColor: isDark ? Colors.black26 : const Color(0xFFFFE6ED),
        title: Text(
          'Questions',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AskQuestionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map<Widget>((filter) {
                  final isSelected = _selectedFilter == filter;
                  final Color selectedBgColor = isDark
                      ? const Color(0xFF3DA89A).withOpacity(0.2)
                      : const Color(0xFF4DB8A8).withOpacity(0.1);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
                      selectedColor: selectedBgColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3DA89A)
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF3DA89A)
                            : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Questions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildQuestionCard(
                  context,
                  question: 'How to solve quadratic equations using the quadratic formula?',
                  author: 'Alex M.',
                  tags: ['Math', 'Algebra'],
                  answers: 5,
                  votes: 12,
                  views: 234,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  question: 'What are the differences between mitosis and meiosis?',
                  author: 'Emma S.',
                  tags: ['Biology', 'Cell Division'],
                  answers: 3,
                  votes: 8,
                  views: 156,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  question: 'Can someone explain Newton\'s Third Law with examples?',
                  author: 'Ryan P.',
                  tags: ['Physics', 'Mechanics'],
                  answers: 7,
                  votes: 15,
                  views: 412,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  question: 'Best approach to memorize the periodic table?',
                  author: 'Olivia K.',
                  tags: ['Chemistry', 'Study Tips'],
                  answers: 12,
                  votes: 24,
                  views: 589,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  question: 'How do I prepare for competitive coding interviews?',
                  author: 'David L.',
                  tags: ['Programming', 'Career'],
                  answers: 9,
                  votes: 18,
                  views: 367,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context, {
    required String question,
    required String author,
    required List<String> tags,
    required int answers,
    required int votes,
    required int views,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionDetailScreen(
              question: question,
              author: author,
              tags: tags,
              votes: votes,
              views: views,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              question,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF34495E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3DA89A).withOpacity(0.2)
                        : const Color(0xFF4DB8A8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF3DA89A).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3DA89A),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                  ),
                ),
                const Spacer(),
                _buildStat(Icons.check_circle_outline, '$answers', isDark),
                const SizedBox(width: 16),
                _buildStat(Icons.arrow_upward, '$votes', isDark),
                const SizedBox(width: 16),
                _buildStat(Icons.visibility_outlined, '$views', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// Ask Question Screen
class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        shadowColor: isDark ? Colors.black26 : const Color(0xFFFFE6ED),
        title: Text(
          'Ask a Question',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Question Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                  hintText: 'Be specific and clear...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Details
            Text(
              'Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _detailsController,
                maxLines: 8,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                  hintText: 'Provide additional context and details...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tags
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF34495E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _tagsController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                  hintText: 'Add tags (e.g., Math, Physics)',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty ||
                        _detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Question posted!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Post Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
