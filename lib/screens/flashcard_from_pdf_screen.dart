import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardFromPdfScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  
  const FlashcardFromPdfScreen({super.key, required this.flashcards});

  @override
  State<FlashcardFromPdfScreen> createState() => _FlashcardFromPdfScreenState();
}

class _FlashcardFromPdfScreenState extends State<FlashcardFromPdfScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = widget.flashcards[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: Text('Flashcards (${_currentIndex + 1}/${widget.flashcards.length})'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showAnswer = !_showAnswer),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16213E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showAnswer ? 'Answer' : 'Question',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _showAnswer ? card.back : card.front,
                            style: TextStyle(
                              fontSize: 20,
                              color: isDark ? Colors.white : const Color(0xFF34495E),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Tap to ${_showAnswer ? "see question" : "reveal answer"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                ),
                IconButton(
                  onPressed: _currentIndex < widget.flashcards.length - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
