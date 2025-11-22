import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String question;
  final String author;
  final List<String> tags;
  final int votes;
  final int views;

  const QuestionDetailScreen({
    super.key,
    required this.question,
    required this.author,
    required this.tags,
    required this.votes,
    required this.views,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _answerController = TextEditingController();
  int _votes = 0;
  bool _hasUpvoted = false;

  @override
  void initState() {
    super.initState();
    _votes = widget.votes;
  }

  @override
  void dispose() {
    _answerController.dispose();
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
          'Question',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_outline,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Card
                  Container(
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
                        // Votes and Question
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vote Section
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_hasUpvoted) {
                                        _votes--;
                                        _hasUpvoted = false;
                                      } else {
                                        _votes++;
                                        _hasUpvoted = true;
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    _hasUpvoted
                                        ? Icons.arrow_upward
                                        : Icons.arrow_upward_outlined,
                                    color: _hasUpvoted
                                        ? const Color(0xFF10B981)
                                        : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                                  ),
                                ),
                                Text(
                                  '$_votes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _hasUpvoted
                                        ? const Color(0xFF10B981)
                                        : (isDark ? Colors.white : const Color(0xFF34495E)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_hasUpvoted) {
                                      setState(() {
                                        _votes--;
                                        _hasUpvoted = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_downward_outlined,
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Question Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.question,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF34495E),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tags
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.tags.map((tag) {
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

                                  // Author & Stats
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.author,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 16,
                                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.views} views',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Answers Section
                  Row(
                    children: [
                      Text(
                        '3 Answers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF34495E),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Sort by',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF4DB8A8) : const Color(0xFF3DA89A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Answers
                  _buildAnswer(
                    'John D.',
                    'The quadratic formula is: x = (-b ± √(b² - 4ac)) / 2a\n\nWhere a, b, and c are coefficients from the equation ax² + bx + c = 0. Simply substitute your values and solve!',
                    15,
                    true,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildAnswer(
                    'Maria S.',
                    'I find it helpful to remember the discriminant (b² - 4ac) first. If it\'s negative, you\'ll have complex roots. If it\'s zero, one root. If positive, two real roots.',
                    8,
                    false,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildAnswer(
                    'Tom R.',
                    'Check out Khan Academy\'s video on this topic. They explain it with great examples!',
                    3,
                    false,
                    isDark,
                  ),
                ],
              ),
            ),
          ),

          // Answer Input
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _answerController,
                      maxLines: 3,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your answer...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_answerController.text.trim().isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Answer posted!')),
                            );
                            _answerController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Post Answer',
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnswer(
    String author,
    String answer,
    int votes,
    bool isAccepted,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
          width: isAccepted ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAccepted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Accepted Answer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          if (isAccepted) const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                author,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF34495E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                '$votes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
