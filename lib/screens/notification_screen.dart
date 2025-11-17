import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? AppTheme.surface : AppTheme.primary,
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _NotificationCard(
              title: 'Welcome!',
              message: 'Thanks for joining Ostaad. Start learning today!',
              icon: Icons.star,
            ),
            _NotificationCard(
              title: 'Daily Quiz Available',
              message: 'Your daily quiz is ready. Take it now!',
              icon: Icons.quiz,
            ),
            _NotificationCard(
              title: 'New Badge Earned',
              message: 'Congrats! You earned the "Consistency" badge.',
              icon: Icons.emoji_events,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  const _NotificationCard({required this.title, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 18),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      ),
    );
  }
}
