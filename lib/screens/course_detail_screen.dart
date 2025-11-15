import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseName;

  const CourseDetailScreen({super.key, required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseName), backgroundColor: AppTheme.primary),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(courseName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              const Text('Course overview', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('This is a placeholder course detail screen. Replace with real content (lessons, quizzes, notes).'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Start Course'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
