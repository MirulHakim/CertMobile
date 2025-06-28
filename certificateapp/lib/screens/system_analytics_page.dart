import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemAnalyticsPage extends StatefulWidget {
  const SystemAnalyticsPage({super.key});

  @override
  State<SystemAnalyticsPage> createState() => _SystemAnalyticsPageState();
}

class _SystemAnalyticsPageState extends State<SystemAnalyticsPage> {
  int caCount = 0;
  int clientCount = 0;
  int recipientCount = 0;
  int certRequestCount = 0;
  int issuedCertCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => isLoading = true);
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      caCount = usersSnapshot.docs
          .where((d) => (d['role']?.toString().toLowerCase() ==
              'certificate authorities (cas)'))
          .length;
      clientCount = usersSnapshot.docs
          .where((d) => (d['role']?.toString().toLowerCase() == 'client'))
          .length;
      recipientCount = usersSnapshot.docs
          .where((d) => (d['role']?.toString().toLowerCase() == 'recipients'))
          .length;

      // Certificate Requests: count documents in 'certificate_requests' collection
      final certReqSnapshot = await FirebaseFirestore.instance
          .collection('certificate_requests')
          .get();
      certRequestCount = certReqSnapshot.size;

      // Issued Certificates: count documents in 'certificates' collection
      final issuedCertSnapshot =
          await FirebaseFirestore.instance.collection('certificates').get();
      issuedCertCount = issuedCertSnapshot.size;
    } catch (e) {
      // Optionally show error
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _AnalyticsButton(
                    icon: Icons.verified_user,
                    label: 'Certificate Authorities',
                    value: caCount,
                    color: Colors.blue,
                  ),
                  _AnalyticsButton(
                    icon: Icons.table_chart,
                    label: 'Clients',
                    value: clientCount,
                    color: Colors.teal,
                  ),
                  _AnalyticsButton(
                    icon: Icons.person,
                    label: 'Recipients',
                    value: recipientCount,
                    color: Colors.indigo,
                  ),
                  _AnalyticsButton(
                    icon: Icons.request_page,
                    label: 'Total Certificate Requests',
                    value: certRequestCount,
                    color: Colors.orange,
                  ),
                  _AnalyticsButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Total Issued Certificates',
                    value: issuedCertCount,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
    );
  }
}

class _AnalyticsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _AnalyticsButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: null, // No action for now
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
