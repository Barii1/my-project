import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable app logo widget. Shows the app SVG inside a rounded white container.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const AppLogo({super.key, this.size = 120, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final double inner = size * 0.72;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.18),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha((0.12 * 255).round()), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/pocket_tutor_logo.svg',
                width: inner,
                height: inner,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.12 * 255).round()), blurRadius: 4)],
                ),
                child: const Icon(Icons.star, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
