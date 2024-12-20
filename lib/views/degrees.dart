import 'package:flutter/material.dart';

class Degrees extends StatelessWidget {
  final String title;

  const Degrees({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text('Degrees!'),
      ),
    );
  }
}