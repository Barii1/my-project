import 'package:flutter/material.dart';

class StudyGroupDetailScreen extends StatefulWidget {
  final String name;
  final String topic;
  final int members;
  final String emoji;
  final Color color;
  final bool isJoined;

  const StudyGroupDetailScreen({
    super.key,
    required this.name,
    required this.topic,
    required this.members,
    required this.emoji,
    required this.color,
    this.isJoined = false,
  });

  @override
  State<StudyGroupDetailScreen> createState() => _StudyGroupDetailScreenState();
}

class _StudyGroupDetailScreenState extends State<StudyGroupDetailScreen> {
  late bool _isJoined;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isJoined = widget.isJoined;
  }

  @override
  void dispose() {
    _messageController.dispose();
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
          widget.name,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF34495E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : const Color(0xFF34495E),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Info Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.3),
                        widget.color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.topic,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.members} members',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _isJoined
                          ? null
                          : LinearGradient(
                              colors: [widget.color, widget.color.withOpacity(0.8)],
                            ),
                      color: _isJoined
                          ? (isDark ? const Color(0xFF2A2E45) : const Color(0xFFF3F4F6))
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: _isJoined
                          ? Border.all(
                              color: isDark ? const Color(0xFF3A3E55) : const Color(0xFFE5E7EB),
                            )
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isJoined = !_isJoined;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isJoined ? 'Joined group!' : 'Left group'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isJoined ? 'Leave Group' : 'Join Group',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isJoined
                              ? (isDark ? Colors.white : const Color(0xFF64748B))
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages/Chat
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildMessage(
                  'Sarah K.',
                  'Hey everyone! Ready for today\'s session?',
                  '10:30 AM',
                  '🎯',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildMessage(
                  'Mike T.',
                  'Yes! I have a few questions about binary trees.',
                  '10:32 AM',
                  '💡',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildMessage(
                  'Emma L.',
                  'I found this great resource on traversal algorithms!',
                  '10:35 AM',
                  '📚',
                  isDark,
                  hasAttachment: true,
                ),
                const SizedBox(height: 12),
                _buildMessage(
                  'Jordan P.',
                  'Thanks Emma! That\'s super helpful.',
                  '10:40 AM',
                  '👍',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildMessage(
                  'Sarah K.',
                  'Let\'s start in 5 minutes. See you all on the call!',
                  '10:55 AM',
                  '🎯',
                  isDark,
                ),
              ],
            ),
          ),

          // Message Input
          if (_isJoined)
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.color, widget.color.withOpacity(0.8)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message sent!')),
                            );
                            _messageController.clear();
                          }
                        },
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
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

  Widget _buildMessage(
    String author,
    String message,
    String time,
    String avatar,
    bool isDark, {
    bool hasAttachment = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(avatar, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF34495E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                  height: 1.4,
                ),
              ),
              if (hasAttachment) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? widget.color.withOpacity(0.1)
                        : widget.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: widget.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'traversal_algorithms.pdf',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
