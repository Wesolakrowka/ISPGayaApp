import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  final String activity;
  final String details;

  const ActivityDetails({super.key, required this.activity, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity),
        backgroundColor: const Color(0xFFFA8742
),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity: $activity',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Details:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(details, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
