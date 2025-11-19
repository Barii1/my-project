import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CircularProgressRing extends StatefulWidget {
  final double progress; // 0.0..1.0
  final String label; // e.g., 80%
  final List<Color>? gradient;
  final bool celebrateAtFull;

  const CircularProgressRing({
    super.key,
    required this.progress,
    required this.label,
    this.gradient,
    this.celebrateAtFull = true,
  });

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.celebrateAtFull && widget.progress >= 1.0) {
      _confetti.play();
    }
  }

  @override
  void didUpdateWidget(covariant CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _anim = Tween<double>(begin: _anim.value, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller
        ..reset()
        ..forward();
    }
    if (widget.celebrateAtFull && widget.progress >= 1.0 && oldWidget.progress < 1.0) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = widget.gradient ?? const [Color(0xFF00BFA6), Color(0xFF00E5FF)];

    return Stack(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return CustomPaint(
                painter: _RingPainter(
                  progress: _anim.value,
                  colors: colors,
                  neonGlow: isDark,
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 110,
          height: 110,
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 14,
                minimumSize: const Size(4, 4),
                maximumSize: const Size(8, 8),
                colors: const [Colors.white, Colors.cyanAccent, Colors.tealAccent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final List<Color> colors;
  final bool neonGlow;
  _RingPainter({required this.progress, required this.colors, required this.neonGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 6;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..color = Colors.white.withOpacity(0.12);

    canvas.drawCircle(center, radius, bg);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi * progress;

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: colors,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..shader = gradient.createShader(rect);

    if (neonGlow) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 16
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12)
        ..shader = gradient.createShader(rect);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    }

    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors || oldDelegate.neonGlow != neonGlow;
}
