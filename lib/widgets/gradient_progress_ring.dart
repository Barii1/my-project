import 'package:flutter/material.dart';

class GradientProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const GradientProgressRing({
    super.key,
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientRingPainter(
        progress: progress.clamp(0.0, 1.0),
        strokeWidth: strokeWidth,
        gradientColors: gradientColors,
        backgroundColor: backgroundColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      // Gradient progress arc
      final sweep = 2 * 3.141592653589793 * progress;
      final gradient = SweepGradient(
        startAngle: -3.141592653589793 / 2,
        endAngle: -3.141592653589793 / 2 + sweep,
        colors: gradientColors,
      );
      final progPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -3.141592653589793 / 2,
        sweep,
        false,
        progPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}