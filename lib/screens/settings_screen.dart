import 'package:flutter/material.dart';
import 'settings_modern.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SettingsModernScreen(user: user, onLogout: onLogout);
  }
}
