import 'dart:async';
import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class Message {
  final String id;
  final String content;
  final bool isUser;
  final bool hasImage;
  final String? code;
  final String? imageUrl;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    this.hasImage = false,
    this.code,
    this.imageUrl,
  });
}

class AIChatScreen extends StatefulWidget {
  final String course;
  final VoidCallback onBack;

  const AIChatScreen({
    super.key,
    required this.course,
    required this.onBack,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with SingleTickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _loadingController;
  String? _copiedMessageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // update UI when input changes so send button state updates
    _inputController.addListener(() {
      if (mounted) setState(() {});
    });
    // Add initial AI message
    _messages.add(
      Message(
        id: '1',
        content: 'Hi! I\'m your AI tutor for ${widget.course}. How can I help you today?',
        isUser: false,
      ),
    );
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isUser: true,
      ));
      _inputController.clear();
      _isLoading = true;
    });

    _scrollToBottom();
    _loadingController.repeat();

    // Simulate AI response
    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _messages.add(Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: 'Great question about $text! Let me explain...',
          isUser: false,
          code: text.toLowerCase().contains('code') || text.toLowerCase().contains('algorithm')
              ? 'function example() {\n  // Here\'s a sample implementation\n  return "result";\n}'
              : null,
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
      _loadingController.stop();
    });
  }

  Future<void> _handleImageUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    _loadingController.repeat();
    
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'I uploaded an image with a question',
      isUser: true,
      hasImage: true,
    );

    setState(() {
      _messages.add(userMessage);
    });

    Timer(const Duration(seconds: 1), () {
      final aiMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'I can see your image! Let me analyze it and help you solve this problem...',
        isUser: false,
      );

      setState(() {
        _messages.add(aiMessage);
      });
      _scrollToBottom();
    });
  }

  Future<void> _handleCopyCode(String code, String messageId) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() {
      _copiedMessageId = messageId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedMessageId = null;
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // Enhanced Header with Gradient
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 20,
                left: 24,
                right: 24,
              ),
                decoration: BoxDecoration(
                gradient: isDark ? AppTheme.darkGradient : AppTheme.appGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                        color: (isDark ? Colors.black : AppTheme.primary).withAlpha((0.15 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'AI Assistant Online',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu moved here so it doesn't overlap the input area
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'dailyQuiz':
                          Navigator.pushNamed(context, '/dailyQuiz');
                          break;
                        case 'flashcards':
                          Navigator.pushNamed(context, '/flashcards');
                          break;
                        case 'practice':
                          Navigator.pushNamed(context, '/practice');
                          break;
                        case 'notes':
                          Navigator.pushNamed(context, '/notes');
                          break;
                        case 'quiz':
                          Navigator.pushNamed(context, '/quiz');
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'dailyQuiz', child: Text('Daily Quiz')),
                      const PopupMenuItem(value: 'flashcards', child: Text('Flashcards')),
                      const PopupMenuItem(value: 'practice', child: Text('Practice')),
                      const PopupMenuItem(value: 'notes', child: Text('Notes')),
                      const PopupMenuItem(value: 'quiz', child: Text('Quiz')),
                    ],
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.appGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

      // Messages
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _MessageBubble(
                message: message,
                copiedId: _copiedMessageId,
                onCopyCode: _handleCopyCode,
              ),
            );
          },
        ),
      ),

      // Typing indicator
      if (_isLoading)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
    children: List.generate(3, (index) {
      return AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  final animation = sin((_loadingController.value * 2 * pi) + (index * pi / 2));
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.translate(
                      offset: Offset(0, -3 * animation),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),            // Input
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                          ),
                        ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withAlpha((0.1 * 255).round()) : AppTheme.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _handleImageUpload,
                      icon: Icon(
                        Icons.image_outlined,
                        color: isDark ? Colors.white : AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.15 * 255).round()),
                            ),
                          ),
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: (_) => _handleSend(),
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                            ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: _inputController.text.trim().isEmpty
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                          : AppTheme.appGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _inputController.text.trim().isEmpty ? null : _handleSend,
                      icon: Icon(Icons.send,
                          color: _inputController.text.trim().isEmpty ? Colors.white70 : Colors.white),
                      disabledColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final String? copiedId;
  final Function(String code, String messageId) onCopyCode;

  const _MessageBubble({
    required this.message,
    required this.copiedId,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppTheme.appGradient : null,
          color: message.isUser
              ? null
              : isDark
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
        ? null
        : Border.all(
          color: isDark
            ? Colors.white.withAlpha((0.1 * 255).round())
            : AppTheme.slate.withAlpha((0.1 * 255).round()),
        ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (message.hasImage) ...[
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Colors.white.withAlpha((0.5 * 255).round()),
                ),
              ),
            ],
            if (message.code != null) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        message.code!,
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => onCopyCode(message.code!, message.id),
                        icon: Icon(
                          copiedId == message.id ? Icons.check : Icons.copy,
                          size: 20,
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        splashRadius: 20,
                        tooltip: 'Copy code',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}