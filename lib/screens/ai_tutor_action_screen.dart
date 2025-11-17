import 'package:flutter/material.dart';

class AiTutorActionScreen extends StatelessWidget {
  final String title;
  const AiTutorActionScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}
