import 'package:flutter/material.dart';

class ProgressCardsRow extends StatelessWidget {
  const ProgressCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _DailyGoalCard()),
        SizedBox(width: 16),
        Expanded(child: _TotalXpCard()),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF2A2E45)) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0,2)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3DA89A)),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFF3DA89A), shape: BoxShape.circle),
                  child: const Icon(Icons.adjust, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('65%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937))),
          const SizedBox(height: 4),
          Text('Daily Goal', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _TotalXpCard extends StatelessWidget {
  const _TotalXpCard();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF2A2E45)) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0,2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 40),
          ),
          const SizedBox(height: 16),
          Text('3,420', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937))),
          const SizedBox(height: 4),
          Text('Total XP', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
