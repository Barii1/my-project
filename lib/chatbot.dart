// lib/chat_page.dart
import 'package:flutter/material.dart';
import 'services/groq_service.dart';

// This chat page now uses only Groq.

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Always use Groq now.

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Build conversation without duplicating last user (already added above).
      final history = _messages
          .map((m) => {'role': m['role']!, 'content': m['text']!})
          .toList();
      final reply = await GroqChatService.sendConversation(history);
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Error: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Column(
        children: [
          // Header - styled like other screens
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Muallim',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF34495E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      onPressed: () => setState(() => _messages.clear()),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Ask me anything!',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF4DB8A8)
                                : (isDark ? const Color(0xFF16213E) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: isUser
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? const Color(0xFF2A2E45)
                                        : const Color(0xFFE5E7EB),
                                  ),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF34495E)),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A2E45)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Thinking...',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A2E45)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF4DB8A8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_controller.text),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
