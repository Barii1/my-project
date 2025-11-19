import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/activity.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All';
  final List<String> _filters = ['All', 'CS', 'Math', 'Today'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'quiz':
        return AppTheme.primary;
      case 'ai':
        return AppTheme.secondary;
      case 'note':
        return AppTheme.warning;
      case 'flashcard':
        return AppTheme.purple;
      default:
        return AppTheme.slate;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.book_outlined;
      case 'ai':
        return Icons.chat_bubble_outline;
      case 'note':
        return Icons.description_outlined;
      case 'flashcard':
        return Icons.psychology_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  List<Activity> _getFilteredActivities() {
    return activityData.where((activity) {
      final matchesSearch = activity.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _activeFilter == 'All' ||
          activity.subject == _activeFilter ||
          (_activeFilter == 'Today' && activity.date == 'Today');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activities = _getFilteredActivities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: isDark ? AppTheme.surface : AppTheme.primary,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? AppTheme.darkGradient.colors : AppTheme.appGradient.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search activities...',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (context) => _filters
                        .map((f) => PopupMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onSelected: (value) => setState(() => _activeFilter = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final start = activity.subject == 'CS'
                      ? const Color(0xFF7C4DFF)
                      : activity.subject == 'Math'
                          ? const Color(0xFFFF7043)
                          : AppTheme.primary;
                  final end = activity.subject == 'CS'
                      ? const Color(0xFF536DFE)
                      : activity.subject == 'Math'
                          ? const Color(0xFFEF5350)
                          : AppTheme.secondary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            // Gradient left border
                            Container(
                              width: 6,
                              height: 76,
                              margin: const EdgeInsets.only(left: 0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                                gradient: LinearGradient(
                                  colors: [start, end],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                leading: CircleAvatar(
                                  backgroundColor: _getActivityColor(activity.type),
                                  child: Icon(_getActivityIcon(activity.type), color: Colors.white),
                                ),
                                title: Text(activity.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface)),
                                subtitle: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: start.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: start.withAlpha((0.12 * 255).round())),
                                      ),
                                      child: Text(activity.subject,
                                          style: TextStyle(
                                              color: start,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(activity.date,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (activity.score != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('${activity.score}%',
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    const SizedBox(width: 8),
                                    // Faded chevron
                                    ShaderMask(
                                      shaderCallback: (rect) => const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Colors.transparent, Colors.grey],
                                      ).createShader(rect),
                                      blendMode: BlendMode.srcIn,
                                      child: const Icon(Icons.chevron_right, size: 26, color: Colors.grey),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
