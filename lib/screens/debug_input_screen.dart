import 'package:flutter/material.dart';

class DebugInputScreen extends StatelessWidget {
  const DebugInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Input')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type below to verify keyboard/input works:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Test Field',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => Text('Current: "${value.text}"'),
            ),
          ],
        ),
      ),
    );
  }
}