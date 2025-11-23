import 'package:flutter/material.dart';
import '../../services/offline_storage_service.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';

class OfflineStorageScreen extends StatefulWidget {
  const OfflineStorageScreen({super.key});

  @override
  State<OfflineStorageScreen> createState() => _OfflineStorageScreenState();
}

class _OfflineStorageScreenState extends State<OfflineStorageScreen> {
  Map<String, int> _storageInfo = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  void _loadStorageInfo() {
    setState(() {
      _storageInfo = OfflineStorageService.getStorageInfo();
      _loading = false;
    });
  }

  Future<void> _clearCache() async {
    await OfflineStorageService.clearCache();
    _loadStorageInfo();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully!')),
    );
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Offline Data?'),
        content: const Text(
          'This will delete all cached quizzes, flashcards, notes, and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OfflineStorageService.clearAllData();
      _loadStorageInfo();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All offline data cleared!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivity = Provider.of<ConnectivityService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Storage'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Connection Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: connectivity.isOnline
                        ? Colors.green.withAlpha((0.1 * 255).round())
                        : Colors.orange.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: connectivity.isOnline ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                        color: connectivity.isOnline ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connectivity.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: connectivity.isOnline ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              connectivity.isOnline
                                  ? 'Data syncing enabled'
                                  : 'Using cached data',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Storage Info
                Text(
                  'Cached Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                _buildStorageCard(
                  'Quiz Data',
                  _storageInfo['quiz_items'] ?? 0,
                  Icons.quiz,
                  Colors.blue,
                ),
                const SizedBox(height: 12),

                _buildStorageCard(
                  'Flashcard Decks',
                  _storageInfo['flashcard_decks'] ?? 0,
                  Icons.style,
                  Colors.purple,
                ),
                const SizedBox(height: 12),

                _buildStorageCard(
                  'Notes',
                  _storageInfo['notes'] ?? 0,
                  Icons.note,
                  Colors.orange,
                ),
                const SizedBox(height: 12),

                _buildStorageCard(
                  'Progress Data',
                  _storageInfo['progress_items'] ?? 0,
                  Icons.trending_up,
                  Colors.green,
                ),
                const SizedBox(height: 12),

                _buildStorageCard(
                  'Cache Items',
                  _storageInfo['cache_items'] ?? 0,
                  Icons.storage,
                  Colors.teal,
                ),

                const SizedBox(height: 32),

                // Actions
                OutlinedButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Clear Cache'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _clearAllData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Offline Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Offline Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Offline mode caches your quiz data, flashcards, notes, and progress locally. '
                        'You can continue learning even without an internet connection. '
                        'Data will sync automatically when you\'re back online.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStorageCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
