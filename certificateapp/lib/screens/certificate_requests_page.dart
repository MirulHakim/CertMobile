import 'package:flutter/material.dart';

class CertificateRequestsPage extends StatelessWidget {
  const CertificateRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Requests'),
      ),
      body: const Center(
        child: Text(
          'No certificate requests yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
