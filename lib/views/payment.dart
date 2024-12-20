import 'package:flutter/material.dart';

class Payment extends StatelessWidget {
  final String title;

  const Payment({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text("You're late with your payment!"),
      ),
    );
  }
}