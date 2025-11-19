import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  String? selectedDeck;
  int currentCard = 0;
  bool isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _handleFlip() {
    setState(() => isFlipped = !isFlipped);
    if (isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appFlashcards = Provider.of<AppStateProvider>(context).flashcards;
    final activeCards = appFlashcards.isNotEmpty ? appFlashcards : sampleCards;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selectedDeck != null) {
      final progress = ((currentCard + 1) / activeCards.length) * 100;

      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
            child: Column(
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedDeck = null;
                          currentCard = 0;
                          isFlipped = false;
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Back to Decks'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Data Structures Basics',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${currentCard + 1} / ${activeCards.length}',
                          style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha((0.6 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: isDark
                                    ? Colors.white.withAlpha((0.1 * 255).round())
                                    : Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                        valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                // Flashcard
                GestureDetector(
                  onTap: _handleFlip,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            height: 320,
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: angle < pi / 2 ? AppTheme.appGradient : null,
                                color: angle >= pi / 2 ? Theme.of(context).cardColor : null,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  angle < pi / 2 ? 'Question' : 'Answer',
                                  style: TextStyle(
                                    color: (angle < pi / 2 ? Colors.white : Theme.of(context).colorScheme.onSurface)
                                        .withAlpha((0.6 * 255).round()),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  angle < pi / 2
                                      ? activeCards[currentCard].front
                                      : activeCards[currentCard].back,
                                  style: TextStyle(
                                    color: angle < pi / 2
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.onSurface,
                                    fontSize: angle < pi / 2 ? 24 : 20,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  angle < pi / 2 ? 'Tap to reveal answer' : 'Tap to flip back',
                                  style: TextStyle(
                                    color: (angle < pi / 2 ? Colors.white : Theme.of(context).colorScheme.onSurface)
                                        .withAlpha((0.6 * 255).round()),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: currentCard > 0
                            ? () {
                                setState(() {
                                  currentCard--;
                                  isFlipped = false;
                                });
                                _flipController.reset();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withAlpha((0.2 * 255).round())
                                : Theme.of(context).colorScheme.onSurface.withAlpha((0.2 * 255).round()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: currentCard < activeCards.length - 1
                            ? () {
                                setState(() {
                                  currentCard++;
                                  isFlipped = false;
                                });
                                _flipController.reset();
                              }
                            : null,
                        icon: const Text('Next'),
                        label: const Icon(Icons.chevron_right),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Difficulty buttons
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      _DifficultyButton(
                        label: 'Hard',
                        color: AppTheme.error,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      _DifficultyButton(
                        label: 'Medium',
                        color: AppTheme.warning,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      _DifficultyButton(
                        label: 'Easy',
                        color: AppTheme.secondary,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Review with spaced repetition',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withAlpha((0.6 * 255).round()),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Decks
              ...flashcardDecks.map((deck) {
                final masteredPercentage = (deck.mastered / deck.cards) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => setState(() => selectedDeck = deck.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                ? Colors.white.withAlpha((0.1 * 255).round())
                : Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.appGradient,
                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                ),
                                child: const Icon(
                                  Icons.book_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deck.title,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${deck.cards} cards • ${deck.mastered} mastered',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface
                                            .withAlpha((0.6 * 255).round()),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                    color: deck.dueIn == 'Now'
                      ? AppTheme.secondary
                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (deck.dueIn != 'Now')
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                                      ),
                                    if (deck.dueIn != 'Now')
                                      const SizedBox(width: 4),
                                    Text(
                                      deck.dueIn == 'Now' ? 'Study Now' : 'Due in ${deck.dueIn}',
                                      style: TextStyle(
                    color: deck.dueIn == 'Now'
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                                        fontSize: 12,
                                        fontWeight: deck.dueIn == 'Now'
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(
                                'Progress',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha((0.6 * 255).round()),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${masteredPercentage.round()}%',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: masteredPercentage / 100,
                backgroundColor: isDark
                  ? Colors.white.withAlpha((0.1 * 255).round())
                  : Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha((0.3 * 255).round())),
          backgroundColor: color.withAlpha((0.05 * 255).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
 