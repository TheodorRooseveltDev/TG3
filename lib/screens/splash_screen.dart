import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation controller (continuous)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/spalshscreen/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Custom loader at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom wave loader
                    SizedBox(
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(200, 60),
                            painter: WaveLoaderPainter(
                              animationValue: _waveController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Loading text in white
                    const Text(
                      'CASTING YOUR LINE...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveLoaderPainter extends CustomPainter {
  final double animationValue;

  WaveLoaderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final double width = size.width;
    final double height = size.height;
    final double centerY = height / 2;

    // Draw 5 wave circles with different phases
    for (int i = 0; i < 5; i++) {
      final double phase = (animationValue + (i * 0.2)) % 1.0;
      final double x = width / 2 + (i - 2) * 45; // Spacing between circles
      
      // Calculate circle properties based on animation phase
      double radius;
      double opacity;
      
      if (phase < 0.5) {
        // Growing phase
        radius = 5 + (phase * 2) * 15; // From 5 to 20
        opacity = 1.0;
      } else {
        // Shrinking phase
        radius = 20 - ((phase - 0.5) * 2) * 15; // From 20 to 5
        opacity = 1.0 - ((phase - 0.5) * 2); // Fade out
      }

      // Create gradient for each circle (white colors)
      final gradient = RadialGradient(
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity * 0.7),
          Colors.white.withOpacity(opacity * 0.3),
        ],
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: Offset(x, centerY), radius: radius),
      );

      // Draw the circle
      canvas.drawCircle(Offset(x, centerY), radius, paint);

      // Draw outer ring for extra effect
      if (phase < 0.3) {
        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withOpacity(opacity * 0.5);
        canvas.drawCircle(Offset(x, centerY), radius + 5, ringPaint);
      }
    }

    // Draw connecting wave line (white)
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.3);

    final path = Path();
    path.moveTo(0, centerY);

    for (double x = 0; x <= width; x += 1) {
      final double wavePhase = (x / width + animationValue) * 2 * math.pi;
      final double y = centerY + math.sin(wavePhase * 3) * 10;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WaveLoaderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
