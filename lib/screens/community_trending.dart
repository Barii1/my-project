import 'package:flutter/material.dart';

class CommunityTrendingScreen extends StatelessWidget {
  const CommunityTrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(6, (i) => Card(
          child: ListTile(
            title: Text('Trending Topic ${i+1}'),
            subtitle: const Text('Popular discussion • 120 posts'),
            onTap: () {},
          ),
        )),
      ),
    );
  }
}
