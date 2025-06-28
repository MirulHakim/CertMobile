import 'package:flutter/material.dart';

class SystemLogsPage extends StatelessWidget {
  const SystemLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
      ),
      body: const Center(
        child: Text(
          'No system logs yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
