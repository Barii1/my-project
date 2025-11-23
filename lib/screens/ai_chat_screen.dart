import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_sessions_provider.dart';
import '../services/connectivity_service.dart';

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
  final String? sessionId;

  const AIChatScreen({
    super.key,
    required this.course,
    required this.onBack,
    this.sessionId,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _loadingController;
  String? _copiedMessageId;
  bool _isLoading = false;
  XFile? _pendingImage;
  PlatformFile? _pendingFile;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _inputController.addListener(() {
      if (mounted) setState(() {});
    });
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
    _recordToSession(text);

    _scrollToBottom();
    _loadingController.repeat();

    // Simulate AI response with streaming text
    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final fullText = 'Great question about $text! Let me explain...';
      final codeBlock = text.toLowerCase().contains('code') || text.toLowerCase().contains('algorithm')
          ? 'function example() {\n  // Here\'s a sample implementation\n  return "result";\n}'
          : null;

      setState(() {
        _messages.add(Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: fullText,
          isUser: false,
          code: codeBlock,
        ));
        _isLoading = false;
      });
      _recordToSession(fullText);
      _scrollToBottom();
      _loadingController.stop();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;
    if (!mounted) return;
    setState(() => _pendingImage = image);
  }

  void _sendPendingImage() {
    if (_pendingImage == null) return;
    setState(() {
      _isLoading = true;
    });
    _loadingController.repeat();
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Image question attached',
      isUser: true,
      hasImage: true,
    );
    _messages.add(userMessage);
    _pendingImage = null;
    _recordToSession('Image question attached');
    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final aiMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Got the image! I will walk through its details and help you answer this.',
        isUser: false,
      );
      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      _loadingController.stop();
      _scrollToBottom();
      _recordToSession('Got the image! I will walk through its details...');
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.isEmpty) return;
    setState(() => _pendingFile = result.files.first);
  }

  void _sendPendingFile() {
    if (_pendingFile == null) return;
    setState(() { _isLoading = true; });
    _loadingController.repeat();
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'PDF uploaded: ${_pendingFile!.name}',
      isUser: true,
    );
    _messages.add(userMessage);
    _recordToSession('PDF uploaded: ${_pendingFile!.name}');
    _pendingFile = null;
    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final aiMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'I will extract key points from the PDF and assist you.',
        isUser: false,
      );
      setState(() { _messages.add(aiMessage); _isLoading = false; });
      _loadingController.stop();
      _scrollToBottom();
      _recordToSession('Analyzing uploaded PDF...');
    });
  }

  void _recordToSession(String content) {
    if (widget.sessionId == null) return;
    try {
      final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
      sessions.recordMessage(widget.sessionId!, content);
    } catch (_) {}
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: Stack(
        children: [
          Column(
            children: [
              // Premium Header with Gradient
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 20,
                  left: 24,
                  right: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00E5C2), Color(0xFF00A8A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2600A8A8),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<ConnectivityService>(
                            builder: (context, connectivity, _) => Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: connectivity.isOnline ? Colors.white : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  connectivity.isOnline ? 'AI Assistant Online' : 'Offline - View only',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Removed flashcards/daily quiz menu per user request.
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
          child: const _TypingIndicatorDots(),
        ),

            // Input
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
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0x1A00A8A8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image_outlined, color: Color(0xFF00A8A8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0x1A00A8A8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00A8A8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0x1A00A8A8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF00A8A8)),
                        ),
                      ),
                    ],
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
                  Row(
                    children: [
                      if (_pendingImage != null)
                        GestureDetector(
                          onTap: _sendPendingImage,
                          child: Container(
                            width: 42,
                            height: 42,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00A8A8)),
                              image: DecorationImage(
                                image: FileImage(
                                  // ignore: deprecated_member_use
                                  // Using File constructor directly for simplicity
                                  // (Assumes proper permissions are configured.)
                                  // Convert XFile path to File
                                  // ignore warning due to restricted imports
                                  // This avoids adding dart:io at top; we can inline below.
                                  // Will be replaced if needed.
                                  // Using dart:io
                                  // Provide a minimal inline File instance
                                  // We add import just above class if missing.
                                  // Actually we should import dart:io.
                                  // We'll patch import.
                                  // placeholder replaced by real File object
                                  // Implementation adjusts below
                                  // but analyzer may need dart:io import.
                                  // We'll patch import at top.
                                  // final file
                                  // ignore comments
                                  File(_pendingImage!.path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.send, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      if (_pendingFile != null)
                        GestureDetector(
                          onTap: _sendPendingFile,
                          child: Container(
                            width: 42,
                            height: 42,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00A8A8)),
                              color: const Color(0xFFE0F2F1),
                            ),
                            child: const Center(child: Icon(Icons.picture_as_pdf, size: 20, color: Color(0xFF00A8A8))),
                          ),
                        ),
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
                ],
              ),
            ),
          ],
        ),
      ],
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
              : (isDark ? const Color(0xFF202124) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(18),
          border: message.isUser
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withAlpha((0.08 * 255).round())
                      : AppTheme.slate.withAlpha((0.12 * 255).round()),
                ),
          boxShadow: [
            if (message.isUser)
              BoxShadow(
                color: AppTheme.primary.withAlpha((0.22 * 255).round()),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400).withAlpha((0.12 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isUser)
              Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            else
              _StreamingText(
                key: ValueKey(message.id),
                text: message.content,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
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

class _StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const _StreamingText({super.key, required this.text, this.style});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    final length = widget.text.length.clamp(1, 2000);
    final durationMs = (length * 35).clamp(400, 2500);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final count = (widget.text.length * _anim.value).floor().clamp(0, widget.text.length);
        final visible = widget.text.substring(0, count);
        return Text(visible, style: widget.style);
      },
    );
  }
}

class _TypingIndicatorDots extends StatefulWidget {
  const _TypingIndicatorDots();

  @override
  State<_TypingIndicatorDots> createState() => _TypingIndicatorDotsState();
}

class _TypingIndicatorDotsState extends State<_TypingIndicatorDots> {
  int _phase = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 280), (_) {
      if (!mounted) return;
      setState(() {
        _phase = (_phase + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseRaw = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i == _phase;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: active ? 10 : 6,
            decoration: BoxDecoration(
            color: Color.fromRGBO((baseRaw.toARGB32() >> 16) & 0xFF, (baseRaw.toARGB32() >> 8) & 0xFF, baseRaw.toARGB32() & 0xFF, 0.6 * (active ? 1.0 : 0.5)),
            shape: BoxShape.circle,
            boxShadow: [
              if (active)
                BoxShadow(
                  color: Color.fromRGBO((baseRaw.toARGB32() >> 16) & 0xFF, (baseRaw.toARGB32() >> 8) & 0xFF, baseRaw.toARGB32() & 0xFF, 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
            ],
          ),
        );
      }),
    );
  }
}

// Mic voice feature removed per user request.