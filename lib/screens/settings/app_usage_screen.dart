import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'dart:math';

// Simple app usage tracker using local storage
// Tracks time spent in app without complex backend
class AppUsageScreen extends StatefulWidget {
  const AppUsageScreen({super.key});

  @override
  State<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> with WidgetsBindingObserver {
  late Future<_UsageData> _future;
  @override
  void initState() {
    super.initState();
    _future = _loadUsage();
  }
  
  Future<_UsageData> _loadUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final days = List.generate(7, (i) => now.subtract(Duration(days: now.weekday - 1 - i)));
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final perDayMinutes = <int>[];
    int weeklyTotalMinutes = 0;
    for (var d in days) {
      final key = 'usage_${uid}_${d.year}-${d.month}-${d.day}';
      final secs = prefs.getInt(key) ?? 0;
      final mins = (secs / 60).round();
      perDayMinutes.add(mins);
      weeklyTotalMinutes += mins;
    }
    return _UsageData(labels: labels, perDayMinutes: perDayMinutes, weeklyTotalMinutes: weeklyTotalMinutes, todayIndex: now.weekday - 1);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time'),
        actions: [
          IconButton(
            tooltip: 'Reset This Week',
            icon: const Icon(Icons.restore),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final now = DateTime.now();
              final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              for (int i = 0; i < 7; i++) {
                final d = startOfWeek.add(Duration(days: i));
                final key = 'usage_${uid}_${d.year}-${d.month}-${d.day}';
                await prefs.remove(key);
              }
              if (mounted) {
                setState(() => _future = _loadUsage());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screen Time reset for this week')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<_UsageData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final maxMinutes = max(60, data.perDayMinutes.reduce((a, b) => max(a, b))); // at least 1h for scale
  
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = _loadUsage());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('This Week', style: Theme.of(context).textTheme.titleLarge),
                    _TotalChip(minutes: data.weeklyTotalMinutes),
                  ],
                ),
                const SizedBox(height: 16),
                _BarChart(labels: data.labels, values: data.perDayMinutes, maxValue: maxMinutes, highlightIndex: data.todayIndex, isDark: isDark),
                const SizedBox(height: 24),
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...List.generate(7, (i) {
                  final mins = data.perDayMinutes[i];
                  return ListTile(
                    title: Text(data.labels[i]),
                    trailing: Text('${mins} min'),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UsageData {
  final List<String> labels;
  final List<int> perDayMinutes;
  final int weeklyTotalMinutes;
  final int todayIndex;
  _UsageData({required this.labels, required this.perDayMinutes, required this.weeklyTotalMinutes, required this.todayIndex});
}

class _TotalChip extends StatelessWidget {
  final int minutes;
  const _TotalChip({required this.minutes});
  @override
  Widget build(BuildContext context) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final text = hours > 0 ? '${hours}h ${mins}m' : '${mins} min';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<String> labels;
  final List<int> values;
  final int maxValue;
  final int highlightIndex;
  final bool isDark;
  const _BarChart({required this.labels, required this.values, required this.maxValue, required this.highlightIndex, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        final v = values[i];
        final h = (v / maxValue) * 140;
        final isToday = i == highlightIndex;
        return Column(
          children: [
            Text(v > 0 ? '${v}m' : '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF9CA3AF))),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isToday ? [const Color(0xFF4DB8A8), const Color(0xFF3DA89A)] : [const Color(0xFFE5E7EB), const Color(0xFFD1D5DB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.w600 : FontWeight.normal, color: isToday ? const Color(0xFF3DA89A) : const Color(0xFF6B7280))),
          ],
        );
      }),
    );
  }
}

