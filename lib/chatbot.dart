// lib/chatbot.dart - Muallim AI Chat (General Purpose)
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'services/groq_service.dart';

class Message {
  final String id;
  final String content;
  final bool isUser;
  final bool hasImage;
  final String? imageUrl;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    this.hasImage = false,
    this.imageUrl,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late final AnimationController _loadingController;
  XFile? _pendingImage;
  PlatformFile? _pendingFile;
  final TextRecognizer _textRecognizer = TextRecognizer();
  String? _copiedMessageId;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    
    // Welcome message
    _messages.add(Message(
      id: '1',
      content: 'Hi! I\'m Muallim, your AI learning assistant. Ask me anything - I can help with homework, explain concepts, analyze images, or review PDFs. How can I help you today?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // Extract text from image using ML Kit
  Future<String> _extractTextFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text.isEmpty ? 'No text found in image' : recognizedText.text;
  }

  // Extract text from PDF
  String _extractTextFromPdfPath(String pdfPath) {
    final bytes = File(pdfPath).readAsBytesSync();
    final doc = PdfDocument(inputBytes: bytes);
    final buffer = StringBuffer();
    final maxPages = doc.pages.count > 30 ? 30 : doc.pages.count;
    for (int i = 0; i < maxPages; i++) {
      buffer.write(PdfTextExtractor(doc).extractText(startPageIndex: i, endPageIndex: i));
      buffer.write('\n');
    }
    doc.dispose();
    final extracted = buffer.toString();
    if (extracted.isEmpty) return 'No text extracted from PDF';
    if (extracted.length > 15000) {
      return '${extracted.substring(0, 15000)}\n\n[Note: PDF truncated to first 15,000 characters due to size]';
    }
    return extracted;
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty && _pendingImage == null && _pendingFile == null) return;

    String finalMessage = text.trim();
    
    // Handle image or PDF attachment
    if (_pendingImage != null) {
      setState(() => _isLoading = true);
      try {
        final extractedText = await _extractTextFromImagePath(_pendingImage!.path);
        finalMessage = finalMessage.isEmpty
            ? 'I uploaded an image. Here\'s the text I extracted:\n\n$extractedText'
            : '$finalMessage\n\n[Image text: $extractedText]';
      } catch (e) {
        finalMessage = finalMessage.isEmpty
            ? 'I uploaded an image but couldn\'t extract text: $e'
            : '$finalMessage\n\n[Image attached but text extraction failed]';
      }
      setState(() => _isLoading = false);
    }
    
    if (_pendingFile != null) {
      setState(() => _isLoading = true);
      try {
        final extractedText = _extractTextFromPdfPath(_pendingFile!.path!);
        finalMessage = finalMessage.isEmpty
            ? 'I uploaded a PDF. Here\'s the extracted content:\n\n$extractedText'
            : '$finalMessage\n\n[PDF content: $extractedText]';
      } catch (e) {
        finalMessage = finalMessage.isEmpty
            ? 'I uploaded a PDF but couldn\'t extract text: $e'
            : '$finalMessage\n\n[PDF attached but extraction failed]';
      }
      setState(() => _isLoading = false);
    }

    if (finalMessage.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: finalMessage,
        isUser: true,
        hasImage: _pendingImage != null,
        imageUrl: _pendingImage?.path,
      ));
      _isLoading = true;
      _pendingImage = null;
      _pendingFile = null;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
          .toList();
      final reply = await GroqChatService.sendConversation(history);
      
      if (mounted) {
        setState(() {
          _messages.add(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: reply,
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: 'Sorry, I encountered an error: $e',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _pendingImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _pendingFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick PDF: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String messageId) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedMessageId = messageId);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedMessageId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Column(
        children: [
          // Header
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muallim',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF34495E),
                            ),
                          ),
                          Text(
                            'Your AI Learning Assistant',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Chat'),
                            content: const Text('Delete all messages?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _messages.clear();
                                    _messages.add(Message(
                                      id: '1',
                                      content: 'Hi! I\'m Muallim, your AI learning assistant. Ask me anything - I can help with homework, explain concepts, analyze images, or review PDFs. How can I help you today?',
                                      isUser: false,
                                    ));
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: isDark ? Colors.white60 : const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                              isDark ? const Color(0xFF4DB8A8) : const Color(0xFF4DB8A8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Thinking...',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Pending File Preview
          if (_pendingImage != null || _pendingFile != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4DB8A8),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (_pendingImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_pendingImage!.path),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Image attached',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF34495E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  if (_pendingFile != null) ...[
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red[400],
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pendingFile!.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF34495E),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _pendingImage = null;
                        _pendingFile = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Attachment Button
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.image, color: Color(0xFF4DB8A8)),
                                  title: const Text('Upload Image'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _pickImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                  title: const Text('Upload PDF'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _pickPdf();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.attach_file,
                        color: isDark ? Colors.white60 : const Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Text Input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Ask anything...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : const Color(0xFFBDC3C7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                          ),
                          onSubmitted: (text) => _sendMessage(text),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Send Button
                    Container(
                      decoration: BoxDecoration(
                        color: _controller.text.trim().isNotEmpty || _pendingImage != null || _pendingFile != null
                            ? const Color(0xFF4DB8A8)
                            : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _controller.text.trim().isNotEmpty || _pendingImage != null || _pendingFile != null
                            ? () => _sendMessage(_controller.text)
                            : null,
                        icon: Icon(
                          Icons.send,
                          color: _controller.text.trim().isNotEmpty || _pendingImage != null || _pendingFile != null
                              ? Colors.white
                              : (isDark ? Colors.white24 : const Color(0xFFBDC3C7)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB8A8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF4DB8A8)
                        : (isDark ? const Color(0xFF16213E) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.hasImage && message.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        message.content,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : (isDark ? Colors.white : const Color(0xFF34495E)),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!message.isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8),
                    child: InkWell(
                      onTap: () => _copyToClipboard(message.content, message.id),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copiedMessageId == message.id ? Icons.check : Icons.copy,
                            size: 14,
                            color: isDark ? Colors.white38 : const Color(0xFFBDC3C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _copiedMessageId == message.id ? 'Copied' : 'Copy',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : const Color(0xFFBDC3C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
