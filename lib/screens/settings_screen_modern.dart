import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/help_faq_screen.dart';
import 'settings/feedback_screen.dart';
import 'settings/profile_settings_screen.dart';
import 'settings/data_usage_screen.dart';
import 'settings/security_settings_screen.dart';
import 'settings/delete_account_screen.dart';
import 'database_test_screen.dart';

class SettingsScreenModern extends StatelessWidget {
  final Map<String, String> user;
  final VoidCallback onLogout;

  const SettingsScreenModern({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildProfileCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Preferences'),
            _buildSettingsGroup(context, [
              Builder(
                builder: (context) {
                  final themeProvider = Provider.of<ThemeProvider>(context);
                  String themeText;
                  switch (themeProvider.themeMode) {
                    case ThemeMode.light:
                      themeText = 'Light Mode';
                      break;
                    case ThemeMode.dark:
                      themeText = 'Dark Mode';
                      break;
                    case ThemeMode.system:
                      themeText = 'System Default';
                      break;
                  }
                  return _buildSettingsItem(
                    context,
                    icon: Icons.palette_outlined,
                    iconColor: const Color(0xFF9B59B6),
                    title: 'Appearance',
                    subtitle: themeText,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AppearanceSettingsScreen()));
                    },
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF3498DB),
                title: 'Notifications',
                subtitle: 'Enabled',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const NotificationsSettingsScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.data_usage,
                iconColor: const Color(0xFF2ECC71),
                title: 'Data Usage',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DataUsageScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Support'),
            _buildSettingsGroup(context, [
              _buildSettingsItem(
                context,
                icon: Icons.help_outline,
                iconColor: const Color(0xFFE67E22),
                title: 'Help & FAQ',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpFaqScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.feedback_outlined,
                iconColor: const Color(0xFFE74C3C),
                title: 'Send Feedback',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FeedbackScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.storage_outlined,
                iconColor: const Color(0xFF16A085),
                title: 'Test Database Connection',
                subtitle: 'Verify Firestore',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DatabaseTestScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Account'),
            _buildSettingsGroup(context, [
              _buildSettingsItem(
                context,
                icon: Icons.security_outlined,
                iconColor: const Color(0xFF34495E),
                title: 'Security',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFC0392B),
                title: 'Delete Account',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen()));
                },
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      'Settings',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF34495E),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF3DA89A),
            child: Text(
              'B',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF34495E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()));
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF3DA89A)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED)),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    );
                  },
                ),
              ),
              if (subtitle != null)
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Icon(Icons.chevron_right, color: isDark ? Colors.white54 : const Color(0xFF9CA3AF));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFE53E3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
