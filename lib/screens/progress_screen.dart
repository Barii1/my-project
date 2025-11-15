import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const List<Map<String, Object>> weeklyData = [
    {'day': 'Mon', 'score': 75.0},
    {'day': 'Tue', 'score': 82.0},
    {'day': 'Wed', 'score': 78.0},
    {'day': 'Thu', 'score': 88.0},
    {'day': 'Fri', 'score': 85.0},
    {'day': 'Sat', 'score': 92.0},
    {'day': 'Sun', 'score': 87.0},
  ];

  static const List<Map<String, Object>> allBadges = [
    {'name': '7-Day Streak', 'earned': true, 'icon': '🔥'},
    {'name': 'Quiz Master', 'earned': true, 'icon': '🎯'},
    {'name': 'Note Taker', 'earned': true, 'icon': '📝'},
    {'name': 'AI Explorer', 'earned': false, 'icon': '🤖'},
    {'name': 'Community Helper', 'earned': false, 'icon': '🤝'},
    {'name': '30-Day Streak', 'earned': false, 'icon': '⭐'},
    {'name': 'Perfect Score', 'earned': false, 'icon': '💯'},
    {'name': 'Early Bird', 'earned': false, 'icon': '🌅'},
  ];

  static const List<Map<String, Object>> skillTree = [
    {'skill': 'Data Structures', 'level': 3, 'maxLevel': 5, 'progress': 60.0},
    {'skill': 'Algorithms', 'level': 2, 'maxLevel': 5, 'progress': 40.0},
    {'skill': 'Calculus', 'level': 4, 'maxLevel': 5, 'progress': 80.0},
    {'skill': 'Linear Algebra', 'level': 2, 'maxLevel': 5, 'progress': 35.0},
  ];

  Widget _buildSimpleBarChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weeklyData.map((entry) {
          final score = (entry['score'] as double) / 100;
          return Flexible(
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${(entry['score'] as double).toInt()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(isDark ? 0xB3 : 0xFF))),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: score,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                            gradient: AppTheme.appGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(entry['day'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()), fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * -10), child: child)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Progress', style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Track your learning journey', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withAlpha((0.6 * 255).round()))),
                    ],
                ),
              ),

              const SizedBox(height: 18),

              // Weekly Performance
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.08 * 255).round())),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                        Icon(Icons.trending_up, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text('Weekly Performance', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      _buildSimpleBarChart(context),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Skill Tree
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.08 * 255).round())),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.track_changes, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text('Skill Tree', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      Column(
                        children: skillTree.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final skill = entry.value;
                          final progress = skill['progress'] as double;
                          final level = skill['level'] as int;
                          final maxLevel = skill['maxLevel'] as int;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress / 100),
                            duration: Duration(milliseconds: 500 + idx * 80),
                            builder: (context, value, child) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(skill['skill'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
                                  Text('Level $level/$maxLevel', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withAlpha((0.6 * 255).round()), fontSize: 12)),
                                ]),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    minHeight: 10,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Performance Insights
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child)),
                child: Container(
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.warning.withAlpha((0.06 * 255).round()), AppTheme.error.withAlpha((0.04 * 255).round())], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.warning.withAlpha((0.08 * 255).round())),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Performance Insight', style: TextStyle(color: isDark ? Colors.white : AppTheme.slate, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text("You're doing great! Consider spending more time on Recursion topics to improve your Data Structures score.", style: TextStyle(color: isDark ? Colors.white70 : AppTheme.slate.withAlpha((0.8 * 255).round()), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Badges
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.08 * 255).round())),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.emoji_events, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text('Badges Unlocked', style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: allBadges.map((badge) {
                          final earned = badge['earned'] as bool;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: earned ? AppTheme.appGradient : null,
                                  color: earned ? null : Theme.of(context).cardColor,
                                ),
                                child: Center(child: Text(badge['icon'] as String, style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(height: 8),
                              Text(badge['name'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppTheme.slate.withAlpha((0.8 * 255).round()))),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
