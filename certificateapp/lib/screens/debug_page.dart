import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;
  String _debugInfo = '';
  final List<String> _logMessages = [];

  void _addLog(String message) {
    setState(() {
      _logMessages
          .add('${DateTime.now().toString().substring(11, 19)}: $message');
      _debugInfo = _logMessages.join('\n');
    });
    debugPrint(message);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (userCredential != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in with Google!')),
          );
          // DO NOT navigate manually!
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testFirebaseAuth() async {
    setState(() {
      _isLoading = true;
      _logMessages.clear();
    });

    _addLog('=== Testing Firebase Auth ===');

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      _addLog('Current Firebase user: ${currentUser?.email ?? 'None'}');

      if (currentUser != null) {
        _addLog('User ID: ${currentUser.uid}');
        _addLog('Email verified: ${currentUser.emailVerified}');
        _addLog(
            'Provider data: ${currentUser.providerData.map((p) => p.providerId).toList()}');
      }
    } catch (e) {
      _addLog('Firebase Auth error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _logMessages.clear();
    });

    _addLog('=== Signing Out ===');

    try {
      await _googleAuthService.signOut();
      await FirebaseAuth.instance.signOut();
      _addLog('✅ Sign out successful');
    } catch (e) {
      _addLog('❌ Sign out error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Debug'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Google Sign-In'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testFirebaseAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Firebase Auth'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),

            // Debug info
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo.isEmpty
                        ? 'Click "Test Google Sign-In" to start debugging...'
                        : _debugInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
