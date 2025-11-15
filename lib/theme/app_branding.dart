import 'package:flutter/material.dart';

class AppBranding {
  // App color scheme
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF16A34A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Logo widget that loads the generated app image (falls back to a simple box)
  static Widget logo({double size = 40}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          // user-provided generated image (using reasonable assumption of path)
          'assets/images/generated-image.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            // fallback to a simple brand box if asset is missing
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: size * 0.6,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // App name with logo in a row
  static Widget brandWithText({double height = 40}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo(size: height),
        const SizedBox(width: 12),
        const Text(
          'Ostaad',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}