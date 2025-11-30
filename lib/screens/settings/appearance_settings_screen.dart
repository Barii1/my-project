import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
// Unused imports removed

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        shadowColor: isDark ? Colors.black26 : const Color(0xFFFFE6ED),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Theme'),
          _buildThemeOption(
            context,
            title: 'Light Mode',
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          _buildThemeOption(
            context,
            title: 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          _buildThemeOption(
            context,
            title: 'System Default',
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isSelected ? const Color(0xFF3DA89A) : (isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED)),
            width: isSelected ? 2 : 1),
      ),
      child: RadioListTile<ThemeMode>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF34495E),
          ),
        ),
        activeColor: const Color(0xFF3DA89A),
      ),
    );
  }

  // Removed unused _saveUserData to fix lint error
}
