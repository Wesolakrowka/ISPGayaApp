import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  final String title;

  const Schedule({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text("it's christmas! 🎄 You are free!!!!"),
      ),
    );
  }
}