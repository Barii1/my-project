import 'package:flutter/material.dart';

class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen> {
  bool _autoDownloadImages = true;
  bool _autoDownloadVideos = false;
  bool _wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Data Usage'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF34495E),
        elevation: 1,
        shadowColor: const Color(0xFFFFE6ED),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDataCard(),
          const SizedBox(height: 24),
          _buildSettingsGroup([
            _buildSwitchItem(
              title: 'Auto-download Images',
              subtitle: 'Download images automatically',
              value: _autoDownloadImages,
              onChanged: (value) {
                setState(() {
                  _autoDownloadImages = value;
                });
              },
            ),
            _buildSwitchItem(
              title: 'Auto-download Videos',
              subtitle: 'Download videos automatically',
              value: _autoDownloadVideos,
              onChanged: (value) {
                setState(() {
                  _autoDownloadVideos = value;
                });
              },
            ),
            _buildSwitchItem(
              title: 'Wi-Fi Only',
              subtitle: 'Download only when connected to Wi-Fi',
              value: _wifiOnly,
              onChanged: (value) {
                setState(() {
                  _wifiOnly = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildClearCacheButton(),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Used This Month',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '234 MB',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_down, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '12% less than last month',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE6ED)),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF34495E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF9CA3AF),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3DA89A),
    );
  }

  Widget _buildClearCacheButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE6ED)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Cache'),
                content: const Text('Are you sure you want to clear all cached data? This will free up storage space.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared successfully!')),
                      );
                    },
                    child: const Text('Clear', style: TextStyle(color: Color(0xFFE74C3C))),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.delete_sweep, color: Color(0xFFE74C3C)),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Clear Cache',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF34495E),
                    ),
                  ),
                ),
                Text(
                  '156 MB',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
