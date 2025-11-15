import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
// kept minimal - this clean implementation is a small wrapper UI

class SettingsScreenClean extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const SettingsScreenClean({super.key, required this.user, required this.onLogout});

  @override
  State<SettingsScreenClean> createState() => _SettingsScreenCleanState();
}

class _SettingsScreenCleanState extends State<SettingsScreenClean> {
  String? _currentSubScreen;

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Profile'),
          onTap: () => setState(() => _currentSubScreen = 'profile'),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Appearance'),
          onTap: () => setState(() => _currentSubScreen = 'appearance'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_none),
          title: const Text('Notifications'),
          onTap: () => setState(() => _currentSubScreen = 'notifications'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
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
            if (ok == true) widget.onLogout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    Widget body = _buildMain();
    if (_currentSubScreen == 'profile') body = Center(child: Text('Profile (stub)'));
    if (_currentSubScreen == 'appearance') {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          // Use ListTile + Radio to avoid analyzer/lint deprecations
          // related to the RadioListTile API in some SDK versions.
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
      );
    }
    if (_currentSubScreen == 'notifications') {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: body));
  }
}
