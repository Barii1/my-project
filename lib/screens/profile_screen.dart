import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
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
                        gradient: const LinearGradient(colors: [Color(0xFF00E5C2), Color(0xFF00A8A8)]),
                      shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Color(0x2000A8A8), blurRadius: 16, offset: Offset(0, 4)),
                        ],
                    ),
                      child: const Center(
                      child: Icon(Icons.person_outline, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Student Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
                        const SizedBox(height: 4),
                          const Text('Learning since Sep 2023', style: TextStyle(fontSize: 14, color: Color(0xFF757575), fontFamily: 'Poppins')),
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