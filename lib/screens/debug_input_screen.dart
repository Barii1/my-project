import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class DebugInputScreen extends StatelessWidget {
  const DebugInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final chatService = ChatService();
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Backfill chat metadata (senderId, participantsMap)'),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backfill started...')),
                );
                try {
                  final updated = await chatService.backfillChatMetadata();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backfill complete. Updated $updated messages.')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backfill failed: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}