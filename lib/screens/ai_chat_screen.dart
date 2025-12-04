import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_sessions_provider.dart';
import '../services/chat_history_service.dart';
import '../services/connectivity_service.dart';
import '../services/groq_service.dart';

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
  final TextRecognizer _textRecognizer = TextRecognizer();

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
    _messages.add(Message(
      id: '1',
      content: _getWelcomeMessage(),
      isUser: false,
    ));
  }

  String _getWelcomeMessage() {
    final course = widget.course.toLowerCase();
    
    // Topic-specific suggestions
    final suggestions = <String, String>{
      'arrays & strings': 'Ask me about arrays, strings, time complexity, sliding windows, two pointers, or string manipulation!',
      'linked lists': 'Ask me about linked lists, pointers, reversing lists, detecting cycles, or fast/slow pointer techniques!',
      'stacks & queues': 'Ask me about stacks, queues, LIFO/FIFO, monotonic stacks, or implementing queues with stacks!',
      'trees & bst': 'Ask me about binary trees, BST properties, tree traversal (inorder, preorder, postorder), or balancing!',
      'heaps & priority queues': 'Ask me about min/max heaps, heap operations, priority queues, or heap sort!',
      'graphs & dfs/bfs': 'Ask me about graph representation, DFS, BFS, shortest paths, topological sort, or cycle detection!',
      'dynamic programming': 'Ask me about DP patterns, memoization, tabulation, optimal substructure, or classic DP problems!',
      'sorting & searching': 'Ask me about sorting algorithms (quick, merge, heap), binary search, or time complexity comparisons!',
      'hashing': 'Ask me about hash tables, hash functions, collision resolution, or hash map applications!',
      'greedy algorithms': 'Ask me about greedy strategies, activity selection, Huffman coding, or when to use greedy vs DP!',
      
      // Math topics
      'calculus': 'Ask me about derivatives, integrals, limits, optimization, or applications of calculus!',
      'linear algebra': 'Ask me about matrices, vectors, eigenvalues, linear transformations, or solving systems!',
      'statistics & probability': 'Ask me about distributions, hypothesis testing, confidence intervals, or probability rules!',
      'discrete mathematics': 'Ask me about set theory, logic, combinatorics, graph theory, or number theory!',
      
      // General knowledge
      'world history': 'Ask me about historical events, civilizations, wars, or important historical figures!',
      'science': 'Ask me about physics, chemistry, biology, or scientific concepts and discoveries!',
      'literature': 'Ask me about literary works, authors, genres, themes, or literary analysis!',
      'geography': 'Ask me about countries, capitals, landforms, climate, or world geography facts!',
    };
    
    // Find matching suggestion or use generic one
    String specificSuggestion = '';
    for (final entry in suggestions.entries) {
      if (course.contains(entry.key) || entry.key.contains(course)) {
        specificSuggestion = entry.value;
        break;
      }
    }
    
    // If no specific suggestion found, use generic message
    if (specificSuggestion.isEmpty) {
      specificSuggestion = 'Ask me anything you\'d like to learn!';
    }
    
    return 'Hi! I\'m your AI tutor for ${widget.course}. $specificSuggestion';
  }

  // Extraction helpers
  Future<String> _extractTextFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text.isEmpty ? 'No text found in image' : recognizedText.text;
  }

  String _extractTextFromPdfPath(String pdfPath) {
    final bytes = File(pdfPath).readAsBytesSync();
    final doc = PdfDocument(inputBytes: bytes);
    final buffer = StringBuffer();
    // Limit to first 30 pages for large PDFs to avoid token limits
    final maxPages = doc.pages.count > 30 ? 30 : doc.pages.count;
    for (int i = 0; i < maxPages; i++) {
      buffer.write(PdfTextExtractor(doc).extractText(startPageIndex: i, endPageIndex: i));
      buffer.write('\n');
    }
    doc.dispose();
    final extracted = buffer.toString();
    if (extracted.isEmpty) return 'No text extracted from PDF';
    // If still too long, truncate to ~15000 chars (Groq will chunk further if needed)
    if (extracted.length > 15000) {
      return '${extracted.substring(0, 15000)}\n\n[Note: PDF truncated to first 15,000 characters due to size]';
    }
    return extracted;
  }

  Future<String> _extractTextFromTxtPath(String txtPath) async {
    return await File(txtPath).readAsString();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;
    if (!mounted) return;
    setState(() {
      _pendingImage = image;
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _pendingFile = result.files.first);
  }

  void _handleSend() async {
    final text = _inputController.text.trim();
    
    // Check if we have attachments
    final hasImage = _pendingImage != null;
    final hasFile = _pendingFile != null;
    
    // Need either text or attachment
    if (text.isEmpty && !hasImage && !hasFile) return;

    // Clear input immediately
    _inputController.clear();
    
    // Build message content
    String messageContent = text.isNotEmpty ? text : 'Attachment';
    if (hasImage) messageContent = text.isEmpty ? 'Image attached' : '$text [Image attached]';
    if (hasFile) messageContent = text.isEmpty ? 'Document: ${_pendingFile!.name}' : '$text [${_pendingFile!.name}]';

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: messageContent,
      isUser: true,
      hasImage: hasImage,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _recordToSession(messageContent);
    _loadingController.repeat();
    _scrollToBottom();

    try {
      String finalPrompt = text;
      
      // Process image if attached
      if (hasImage) {
        final imgPath = _pendingImage!.path;
        _pendingImage = null;
        final extracted = await _extractTextFromImagePath(imgPath);
        finalPrompt = text.isNotEmpty 
          ? '''Context: ${widget.course}
User Question: $text

Image text extracted: $extracted

Answer the question using the image context.'''
          : '''You are analyzing an educational image for ${widget.course}.

OCR extracted text:
$extracted

Provide a clear explanation of what this shows and key concepts.''';
      }
      
      // Process document if attached
      if (hasFile) {
        final pathStr = _pendingFile!.path!;
        final ext = p.extension(pathStr).toLowerCase();
        _pendingFile = null;
        
        String extracted;
        if (ext == '.pdf') {
          extracted = _extractTextFromPdfPath(pathStr);
        } else if (ext == '.txt') {
          extracted = await _extractTextFromTxtPath(pathStr);
        } else {
          extracted = await _extractTextFromImagePath(pathStr);
        }
        
        finalPrompt = text.isNotEmpty
          ? '''Context: ${widget.course}
User Question: $text

Document content:
$extracted

Answer based on the document.'''
          : '''Summarize this document for ${widget.course}:

$extracted''';
      }
      
      // If no attachments, just use text with context
      if (!hasImage && !hasFile && text.isNotEmpty) {
        finalPrompt = 'Context: ${widget.course}\n\nQuestion: $text';
      }

      final reply = await GroqChatService.sendMessage(finalPrompt);
      
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: reply,
          isUser: false,
        ));
        _isLoading = false;
      });
      _recordToSession(reply);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: 'Error: $error',
          isUser: false,
        ));
        _isLoading = false;
      });
    } finally {
      _loadingController.stop();
      _scrollToBottom();
    }
  }

  void _recordToSession(String content) {
    if (widget.sessionId == null) return;
    try {
      final sessions = Provider.of<AiChatSessionsProvider>(context, listen: false);
      sessions.recordMessage(widget.sessionId!, content);
      // Persist full message history as well
      ChatHistoryService.appendMessage(widget.sessionId!, {
        'content': content,
        'isUser': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Stack(
        children: [
          Column(
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
                          onPressed: widget.onBack,
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
                                widget.course,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF34495E),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Consumer<ConnectivityService>(
                                builder: (context, connectivity, _) => Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: connectivity.isOnline 
                                          ? const Color(0xFF4DB8A8)
                                          : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      connectivity.isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(
                      message: message,
                      copiedId: _copiedMessageId,
                      onCopyCode: _handleCopyCode,
                    );
                  },
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const _TypingIndicatorDots(),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Input area
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                  // Camera button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x1A00A8A8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00A8A8)),
                      tooltip: 'Take Photo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Gallery button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x1A00A8A8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined, color: Color(0xFF00A8A8)),
                      tooltip: 'Choose Image',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // PDF/Document button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x1A00A8A8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF00A8A8)),
                      tooltip: 'Upload PDF',
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                        ),
                      ),
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: (_) => _handleSend(),
                        decoration: const InputDecoration(
                          hintText: 'Ask anything...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Pending image preview (non-interactive)
                  if (_pendingImage != null)
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00A8A8)),
                            image: DecorationImage(
                              image: FileImage(File(_pendingImage!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () => setState(() => _pendingImage = null),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  // Pending file preview (non-interactive)
                  if (_pendingFile != null)
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00A8A8)),
                            color: const Color(0xFFE0F2F1),
                          ),
                          child: const Center(
                            child: Icon(Icons.picture_as_pdf, size: 20, color: Color(0xFF00A8A8)),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () => setState(() => _pendingFile = null),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  // Send button (enabled if text OR attachments present)
                  Container(
                    decoration: BoxDecoration(
                      gradient: (_inputController.text.trim().isEmpty && _pendingImage == null && _pendingFile == null)
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                          : AppTheme.appGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: (_inputController.text.trim().isEmpty && _pendingImage == null && _pendingFile == null) 
                          ? null 
                          : _handleSend,
                      icon: const Icon(Icons.send, color: Colors.white),
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

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    _textRecognizer.close();
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
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppTheme.appGradient : null,
          color: message.isUser
              ? null
              : (isDark ? const Color(0xFF202124) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i == _phase;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: active ? 10 : 6,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(active ? 0.8 : 0.4),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
