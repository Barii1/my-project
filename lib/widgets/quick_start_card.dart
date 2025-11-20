import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';

class QuickStartCard extends StatefulWidget {
  final String title;
  final String lottieAsset; // e.g., assets/lottie/brain.json
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const QuickStartCard({
    super.key,
    required this.title,
    required this.lottieAsset,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  State<QuickStartCard> createState() => _QuickStartCardState();
}

class _QuickStartCardState extends State<QuickStartCard>
    with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;
  bool _pressed = false;
  late final AnimationController _glowCtl;

  @override
  void initState() {
    super.initState();
    _glowCtl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtl.dispose();
    super.dispose();
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onPanStart(_) => setState(() => _pressed = true);

  void _onPanUpdate(DragUpdateDetails d) {
    // Subtle 3D tilt from drag delta
    const maxTilt = 0.20; // radians ~11.5°
    final dx = d.delta.dx.clamp(-10.0, 10.0) / 10.0;
    final dy = d.delta.dy.clamp(-10.0, 10.0) / 10.0;
    setState(() {
      _tiltY = (dx * maxTilt).clamp(-maxTilt, maxTilt);
      _tiltX = (-dy * maxTilt).clamp(-maxTilt, maxTilt);
    });
  }

  void _onPanEnd(_) {
    setState(() {
      _pressed = false;
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Color.fromRGBO(255, 255, 255, isDark ? 0.08 : 0.12);
    final border = Color.fromRGBO(255, 255, 255, isDark ? 0.18 : 0.22);

    return AnimatedBuilder(
      animation: _glowCtl,
      builder: (context, child) {
        final glowAlpha = (0.22 + 0.12 * _glowCtl.value);
        final glowAlphaUsed = isDark ? glowAlpha : glowAlpha * 0.8;
        final glow = Color.lerp(Colors.transparent, Colors.cyanAccent, glowAlphaUsed)!;

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY);
        final s = _pressed ? 1.02 : 1.0;
        matrix.multiply(Matrix4.diagonal3Values(s, s, s));

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: () => _onPanEnd(null),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            transform: matrix,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, isDark ? 0.35 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: glow,
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: border, width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    color: bg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<bool>(
                          future: _assetExists(widget.lottieAsset),
                          builder: (context, snap) {
                            final exists = snap.data == true;
                            return SizedBox(
                              width: 38,
                              height: 38,
                              child: exists
                                  ? Lottie.asset(
                                      widget.lottieAsset,
                                      repeat: true,
                                      animate: true,
                                      fit: BoxFit.contain,
                                    )
                                  : Icon(widget.fallbackIcon, color: const Color.fromRGBO(255, 255, 255, 0.9)),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, isDark ? 0.95 : 0.98),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
