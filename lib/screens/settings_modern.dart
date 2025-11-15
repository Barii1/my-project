import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class SettingsModernScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const SettingsModernScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(name: user['name'] ?? '', email: user['email'] ?? ''),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Edit name, photo, email',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile coming soon')));
            },
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme preferences',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _AppearanceSettingsPage()),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Manage alerts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _NotificationsSettingsPage()),
            ),
          ),
          _SettingsTile(
            icon: Icons.sd_storage_outlined,
            title: 'Storage',
            subtitle: 'Manage app data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage settings coming soon')));
            },
          ),
          _SettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'Security',
            subtitle: 'Password & 2FA',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings coming soon')));
            },
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Feedback',
            subtitle: 'Get support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & Feedback coming soon')));
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Sign out now?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Sign out')),
                  ],
                ),
              );
              if (ok == true) onLogout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
  final colors = [AppTheme.primary, AppTheme.secondary];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join() : 'AC',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withAlpha(0x11), AppTheme.secondary.withAlpha(0x11)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppearanceSettingsPage extends StatelessWidget {
  const _AppearanceSettingsPage();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('System'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: appState.themeMode,
              onChanged: (v) => appState.setThemeMode(v ?? ThemeMode.system),
            ),
            onTap: () => appState.setThemeMode(ThemeMode.system),
          ),
          ListTile(
            title: const Text('Light'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: appState.themeMode,
              onChanged: (v) => appState.setThemeMode(v ?? ThemeMode.light),
            ),
            onTap: () => appState.setThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: const Text('Dark'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: appState.themeMode,
              onChanged: (v) => appState.setThemeMode(v ?? ThemeMode.dark),
            ),
            onTap: () => appState.setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSettingsPage extends StatelessWidget {
  const _NotificationsSettingsPage();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: appState.pushNotificationsEnabled,
            onChanged: (_) => appState.togglePushNotifications(),
          ),
          SwitchListTile(
            title: const Text('Sync Data Automatically'),
            value: appState.dataSync,
            onChanged: (_) => appState.toggleDataSync(),
          ),
        ],
      ),
    );
  }
}
