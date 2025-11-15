import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile header
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(32),
                      shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                      child: Center(
                      child: Icon(Icons.person_outline, size: 40, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student Profile', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                          Text('Learning since Sep 2023', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats cards
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context: context,
                    title: 'Questions Asked',
                    value: '156',
                    icon: Icons.question_answer_outlined,
                    color: AppTheme.primary,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'Total XP',
                    value: '2,450',
                    icon: Icons.star_outline,
                    color: AppTheme.secondary,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'Study Hours',
                    value: '45',
                    icon: Icons.timer_outlined,
                    color: AppTheme.purple,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'Average Score',
                    value: '85%',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.warning,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildProgressBar(
                      context: context,
                      label: 'Computer Science',
                      progress: 0.75,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                      context: context,
                      label: 'Mathematics',
                      progress: 0.60,
                      color: AppTheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                      context: context,
                      label: 'Physics',
                      progress: 0.45,
                      color: const Color(0xFFE67E22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(progress * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}