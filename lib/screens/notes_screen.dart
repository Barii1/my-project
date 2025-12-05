import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../services/offline_storage_service.dart';
import '../services/groq_service.dart';
import '../services/pdf_extractor_service.dart';
import '../models/flashcard.dart';
import 'flashcard_from_pdf_screen.dart';
import '../services/xp_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Timer? _debounce;
  bool _isSaving = false;
  DateTime? _lastSaved;

  late final AnimationController _animController;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.removeListener(_onChanged);
    _contentController.removeListener(_onChanged);
    _titleController.dispose();
    _contentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _autoSave);
  }

  void _autoSave() {
    // Save to both file system and offline storage
    final title = _titleController.text.isNotEmpty ? _titleController.text : 'untitled';
    final content = _contentController.text;
    
    // Save to offline storage
    final noteData = {
      'title': title,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    OfflineStorageService.saveNote(
      'note_${DateTime.now().millisecondsSinceEpoch}', 
      noteData
    );
    
    // Show saving indicator for a short time then set lastSaved
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isSaving = false;
        _lastSaved = DateTime.now();
      });
      // Award XP for creating/saving a note (debounced)
      XpService().awardXpForNoteOrFlashcardCreated();
    });
  }

  Future<void> _handleImportPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path!;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final extracted = PdfExtractorService.extractText(path);
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      setState(() {
        if (_titleController.text.isEmpty) {
          _titleController.text = result.files.first.name.replaceAll('.pdf', '');
        }
        _contentController.text = extracted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF imported successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _handleSummarizeContent() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content to summarize')),
      );
      return;
    }

    if (content.length < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content is too short to summarize. Add more text.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Summarizing your notes...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final summary = await GroqChatService.summarizeText(content);
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show summary in a dialog
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.summarize, color: Color(0xFF9B59B6)),
              SizedBox(width: 8),
              Text('Summary'),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(summary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(c).pop();
                // Replace content with summary
                _contentController.text = summary;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Use Summary'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      
      String errorMessage = 'Summarization failed';
      if (e.toString().contains('rate') || e.toString().contains('limit') || e.toString().contains('429')) {
        errorMessage = 'API rate limit reached. Please wait a few moments and try again.';
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        errorMessage = 'API authentication failed. Please check your API key.';
      } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again with shorter content.';
      } else {
        final errMsg = e.toString().split(':').last.trim();
        errorMessage = 'Summarization failed: ${errMsg.length > 100 ? "${errMsg.substring(0, 100)}..." : errMsg}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _handleConvertToFlashcards() async {
    // Generate flashcards from current note content
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add content first or import a PDF')),
      );
      return;
    }

    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating flashcards...'),
                ],
              ),
            ),
          ),
        ),
      );

      final flashcardsJson = await GroqChatService.generateFlashcardsFromDocument(content, numCards: 10);
      final flashcards = _parseFlashcardsJson(flashcardsJson);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate flashcards')),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FlashcardFromPdfScreen(flashcards: flashcards),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      
      String errorMessage = 'Flashcard generation failed';
      if (e.toString().contains('rate') || e.toString().contains('limit') || e.toString().contains('429')) {
        errorMessage = 'API rate limit reached. Please wait a few moments and try again.';
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        errorMessage = 'API authentication failed. Please check your API key.';
      } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again with shorter content.';
      } else {
        final errMsg = e.toString().split(':').last.trim();
        errorMessage = 'Flashcard generation failed: ${errMsg.length > 100 ? "${errMsg.substring(0, 100)}..." : errMsg}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  List<Flashcard> _parseFlashcardsJson(String jsonText) {
    try {
      final data = jsonDecode(jsonText) as List;
      return data.map((card) {
        return Flashcard.basic(
          front: card['question'] as String,
          back: card['answer'] as String,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final seconds = diff.inSeconds;
    if (seconds < 60) return 'just now';
    if (seconds < 3600) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 96),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Note',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (_isSaving) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppTheme.warning,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                const Text('Saving...',
                                    style: TextStyle(fontSize: 12)),
                              ] else if (_lastSaved != null) ...[
                const Icon(Icons.check_circle,
                  size: 16, color: AppTheme.secondary),
                                const SizedBox(width: 8),
                                Text('Saved ${_formatTime(_lastSaved!)}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575), fontFamily: 'Poppins')),
                              ] else ...[
                                const Text('Start typing to auto-save',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF757575), fontFamily: 'Poppins')),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons Row 1
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _handleImportPDF,
                          icon: const Icon(Icons.upload_file_outlined, size: 18),
                          label: const Text('Import PDF'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.18 * 255).round())),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleSummarizeContent,
                          icon: const Icon(Icons.summarize_outlined, size: 18),
                          label: const Text('Summarize'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF9B59B6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons Row 2
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleConvertToFlashcards,
                          icon: const Icon(Icons.credit_card_outlined, size: 18),
                          label: const Text('Flashcards'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateQuizFromPdf,
                          icon: const Icon(Icons.quiz_outlined, size: 18),
                          label: const Text('Create Quiz'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4DB8A8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Editor
                  TextField(
                    controller: _titleController,
                      decoration: InputDecoration(
                      hintText: 'Note Title',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round())),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.08 * 255).round()),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 300),
                      child: TextField(
                        controller: _contentController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Start writing your note... Markdown is supported!',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Generate Quiz from PDF flow
  Future<void> _generateQuizFromPdf() async {
    // Generate quiz from current note content (either imported PDF or typed notes)
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add content first or import a PDF'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      if (!mounted) return;
      
      print('📝 Generating quiz from content (${content.length} chars)');
      
      final jsonText = await GroqChatService.generateQuizFromDocument(content, numQuestions: 5);
      print('✅ Received quiz JSON response');
      
      final questions = _parseQuizJson(jsonText);
      print('✅ Parsed ${questions.length} questions');

      if (!mounted) return;
      
      if (questions.isEmpty || (questions.length == 1 && questions[0].stem.contains('Failed to parse'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate quiz. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _GeneratedQuizPlayScreen(questions: questions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      print('❌ Quiz generation error: $e');
      
      String errorMessage = 'Quiz generation failed';
      if (e.toString().contains('rate') || e.toString().contains('limit') || e.toString().contains('429')) {
        errorMessage = 'API rate limit reached. Please wait a few moments and try again.';
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('401') || e.toString().contains('Invalid API key')) {
        errorMessage = 'API authentication failed. Please check your API key.';
      } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Request timed out. Please try again with shorter content.';
      } else if (e.toString().contains('JSON')) {
        errorMessage = 'Failed to process API response. Please try again.';
      } else {
        final errMsg = e.toString().replaceAll('Exception: ', '').trim();
        errorMessage = errMsg.length > 100 ? '${errMsg.substring(0, 100)}...' : errMsg;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red.shade700,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // Removed obsolete basic extractor; using PdfExtractorService instead.

  List<_GenQuestion> _parseQuizJson(String jsonText) {
    try {
      print('🔍 Parsing quiz JSON (length: ${jsonText.length})');
      final data = jsonDecode(jsonText);
      
      if (data is! List) {
        print('❌ JSON is not a list: ${data.runtimeType}');
        throw Exception('Expected JSON array, got ${data.runtimeType}');
      }
      
      if (data.isEmpty) {
        print('❌ JSON array is empty');
        throw Exception('No questions generated');
      }
      
      print('✅ Parsing ${data.length} questions');
      
      return data.map((q) {
        if (q is! Map) {
          throw Exception('Question is not an object');
        }
        final stem = q['stem'] as String;
        final optionsData = q['options'] as List;
        final explanation = (q['explanation'] ?? '') as String;
        final options = optionsData.map((o) => _GenOption(text: o['text'] as String, correct: o['correct'] as bool)).toList();
        return _GenQuestion(stem: stem, options: options, explanation: explanation);
      }).toList();
    } catch (e) {
      print('❌ Quiz JSON parsing error: $e');
      print('📄 JSON content: ${jsonText.substring(0, jsonText.length > 1000 ? 1000 : jsonText.length)}');
      throw Exception('Failed to parse quiz: $e');
    }
  }
}

class _GenQuestion {
  final String stem;
  final List<_GenOption> options;
  final String explanation;
  _GenQuestion({required this.stem, required this.options, required this.explanation});
}

class _GenOption {
  final String text;
  final bool correct;
  _GenOption({required this.text, required this.correct});
}

class _GeneratedQuizPlayScreen extends StatefulWidget {
  final List<_GenQuestion> questions;
  const _GeneratedQuizPlayScreen({required this.questions});

  @override
  State<_GeneratedQuizPlayScreen> createState() => _GeneratedQuizPlayScreenState();
}

class _GeneratedQuizPlayScreenState extends State<_GeneratedQuizPlayScreen> {
  int _index = 0;
  int _score = 0;
  bool _finished = false;

  void _select(_GenOption opt) {
    if (_finished) return;
    if (opt.correct) _score++;
    setState(() {
      if (_index == widget.questions.length - 1) {
        _finished = true;
      } else {
        _index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Quiz')),
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _finished ? _result(isDark) : _question(isDark),
      ),
    );
  }

  Widget _question(bool isDark) {
    final q = widget.questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_index + 1}/${widget.questions.length}', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Text(q.stem, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF34495E))),
        const SizedBox(height: 16),
        ...q.options.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: () => _select(o),
            child: Align(alignment: Alignment.centerLeft, child: Text(o.text)),
          ),
        )),
        const SizedBox(height: 16),
        Text(q.explanation, style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B))),
      ],
    );
  }

  Widget _result(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Score: $_score/${widget.questions.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF34495E))),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              // Award XP for completing this generated quiz
              final total = widget.questions.length;
              final percent = total == 0 ? 0.0 : (_score / total) * 100.0;
              try {
                await XpService().awardXpForQuizCompletion(
                  questionCount: total,
                  scorePercent: percent,
                  noSkippedQuestions: true,
                  subjectId: 'notes-generated',
                );
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Removed unused _CodeChip widget
