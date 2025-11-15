import 'package:flutter/material.dart';

class CommunityCreatePostScreen extends StatelessWidget {
  const CommunityCreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(hintText: "What's on your mind?"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.image), label: const Text('Attach')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text('Post')),
                const Spacer(),
                OutlinedButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text('Cancel')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
