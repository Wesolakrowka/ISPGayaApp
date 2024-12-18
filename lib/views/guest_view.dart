import 'package:flutter/material.dart';

class GuestView extends StatelessWidget {
  final String title;

  const GuestView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Welcome, Guest!'),
      ),
    );
  }
}