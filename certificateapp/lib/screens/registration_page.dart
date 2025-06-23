import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'welcome_page.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;
    final gradientColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.withOpacity(0.8),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top wave/curve
          SizedBox(
            width: double.infinity,
            height: 220,
            child: CustomPaint(
              painter: _TopWavePainter(gradientColors),
            ),
          ),
          // Back button
          Positioned(
            top: 24,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              },
              tooltip: 'Back',
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // App icon/logo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 48,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CERTMOBILE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Get Started!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your digital certificates, organized and secure.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Register with Google button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.account_circle,
                            color: Colors.red, size: 26),
                        label: const Text(
                          'Register with Google',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                          foregroundColor: Colors.black87,
                          backgroundColor: null,
                        ).copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (states) => null,
                          ),
                          // Use gradient background
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the top wave/curve
class _TopWavePainter extends CustomPainter {
  final List<Color> colors;
  _TopWavePainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.55,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
