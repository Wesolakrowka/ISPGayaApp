import 'package:flutter/material.dart';

class Personal extends StatelessWidget {
  final String title;

  const Personal({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text('Your name!'),
      ),
    );
  }
}