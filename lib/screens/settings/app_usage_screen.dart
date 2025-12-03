import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple app usage tracker using local storage
// Tracks time spent in app without complex backend
class AppUsageScreen extends StatefulWidget {
  const AppUsageScreen({super.key});

  @override
  State<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  String _selectedPeriod = 'Today';
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  // Simple method: Read stored usage time from SharedPreferences
  // Backend: Just save timestamps when app opens/closes
  Future<void> _loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'usage_${_selectedPeriod.toLowerCase().replaceAll(' ', '_')}';
    setState(() {
      _totalMinutes = prefs.getInt(key) ?? 0;
    });
  }
  
  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('App Usage'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 80,
                color: const Color(0xFF4DB8A8).withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                _formatTime(_totalMinutes),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedPeriod,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),
              _buildPeriodSelector(isDark),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB8A8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4DB8A8).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4DB8A8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Usage tracking is automatic. Keep using the app!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final periods = ['Today', 'This Week', 'This Month'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadUsageData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4DB8A8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
