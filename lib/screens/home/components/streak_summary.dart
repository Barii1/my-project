import 'package:flutter/material.dart';

class StreakSummary extends StatefulWidget {
  final int streak;
  const StreakSummary({super.key, required this.streak});

  @override
  State<StreakSummary> createState() => _StreakSummaryState();
}

class _StreakSummaryState extends State<StreakSummary> with SingleTickerProviderStateMixin {
  late final AnimationController _flameController;
  late final Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(_flameController);
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x15000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Streak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${widget.streak}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                  const SizedBox(width: 8),
                  const Text('days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _flameAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_flameAnimation.value * 0.1),
                child: const Text('🔥', style: TextStyle(fontSize: 60)),
              );
            },
          ),
        ],
      ),
    );
  }
}
