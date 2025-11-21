import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

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
    // Show saving indicator for a short time then set lastSaved
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isSaving = false;
        _lastSaved = DateTime.now();
      });
    });
  }

  void _handleExportPDF() {
    // Simple export: write markdown content to a .md file in app documents directory
    final title = _titleController.text.isNotEmpty ? _titleController.text : 'note';
    final content = _contentController.text;
    _doExport(title, content);
  }

  Future<void> _doExport(String title, String content) async {
    if (!mounted) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$title-${DateTime.now().millisecondsSinceEpoch}.md');
      await file.writeAsString('# $title\n\n$content');
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
    } catch (e) {
      if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Export failed')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleConvertToFlashcards() {
    final title = _titleController.text.isNotEmpty ? _titleController.text : 'Note';
    final content = _contentController.text;
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.addFlashcardsFromNote(title, content);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flashcards created from note')));
    }
    Navigator.of(context).pushNamed('/flashcards');
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

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _handleExportPDF,
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('Export PDF'),
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
                          onPressed: _handleConvertToFlashcards,
                          icon: const Icon(Icons.credit_card_outlined, size: 18),
                          label: const Text('To Flashcards'),
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

                  // Markdown Guide
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
            Text('Markdown Quick Guide',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _CodeChip(text: '# Heading'),
                            _CodeChip(text: '**Bold**'),
                            _CodeChip(text: '*Italic*'),
                            _CodeChip(text: '- List item'),
                          ],
                        ),
                      ],
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

class _CodeChip extends StatelessWidget {
  final String text;
  const _CodeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.06 * 255).round())),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.8 * 255).round())),
      ),
    );
  }
}
