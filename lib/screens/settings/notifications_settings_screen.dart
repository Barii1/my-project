import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF34495E),
        elevation: 1,
        shadowColor: const Color(0xFFFFE6ED),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsGroup([
            _buildSwitchItem(
              title: 'Push Notifications',
              value: true,
              onChanged: (value) {},
            ),
            _buildSwitchItem(
              title: 'Email Notifications',
              value: false,
              onChanged: (value) {},
            ),
            _buildSwitchItem(
              title: 'In-App Notifications',
              value: true,
              onChanged: (value) {},
            ),
          ]),
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
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF3DA89A),
    );
  }
}
