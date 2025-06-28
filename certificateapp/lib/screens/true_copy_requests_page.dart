import 'package:flutter/material.dart';

class TrueCopyRequestsPage extends StatelessWidget {
  const TrueCopyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('True Copy Requests'),
      ),
      body: const Center(
        child: Text(
          'No true copy requests yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
