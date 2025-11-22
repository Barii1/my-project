import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FA),
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF34495E),
        elevation: 1,
        shadowColor: const Color(0xFFFFE6ED),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem(
            question: 'How do I reset my password?',
            answer: 'You can reset your password from the login screen by tapping on "Forgot Password". You will receive an email with instructions to reset your password.',
            icon: Icons.lock_reset,
            iconColor: const Color(0xFF3498DB),
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: 'How do I change my email?',
            answer: 'Go to Settings > Profile, then tap the edit icon next to your email address. Make sure to verify your new email address.',
            icon: Icons.email,
            iconColor: const Color(0xFF9B59B6),
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: 'How do I enable dark mode?',
            answer: 'Navigate to Settings > Appearance, then select "Dark Mode" from the theme options. You can also choose "System Default" to match your device settings.',
            icon: Icons.dark_mode,
            iconColor: const Color(0xFF34495E),
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: 'How do notifications work?',
            answer: 'You can customize your notification preferences in Settings > Notifications. Choose which types of notifications you want to receive.',
            icon: Icons.notifications,
            iconColor: const Color(0xFF16A085),
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: 'How do I delete my account?',
            answer: 'Go to Settings > Account > Delete Account. Please note that this action is permanent and cannot be undone. All your data will be permanently deleted.',
            icon: Icons.delete_forever,
            iconColor: const Color(0xFFE74C3C),
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: 'How do I contact support?',
            answer: 'You can reach our support team through Settings > Send Feedback. We typically respond within 24-48 hours.',
            icon: Icons.support_agent,
            iconColor: const Color(0xFFE67E22),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE6ED)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34495E),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
