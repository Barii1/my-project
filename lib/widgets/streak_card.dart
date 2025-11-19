import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:confetti/confetti.dart';

class StreakCard extends StatefulWidget {
  final int streak;
  final bool celebrate;
  const StreakCard({super.key, required this.streak, this.celebrate = false});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulse.repeat(reverse: true);
    if (widget.celebrate) {
      _confetti.play();
    }
  }

  @override
  void didUpdateWidget(covariant StreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      const Color(0xFF00BFA6), // teal
      const Color(0xFF00E5FF), // cyan
    ];

    final glow = isDark ? Colors.orange.withAlpha((0.25 * 255).round()) : Colors.transparent;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: glow,
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: widget.streak > 3 ? 1.08 : 1)
                    .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                  child: const ClipOval(
                    child: rive.RiveAnimation.asset(
                      'assets/animations/flame.riv',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.streak} Day Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.streak > 0 ? 'Keep the fire burning!' : 'Start your streak today',
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Confetti overlay
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 24,
                shouldLoop: false,
                colors: const [Colors.white, Colors.yellow, Colors.orange, Colors.redAccent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
