import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool hero;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.hero = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(),
        if (showText) ...[
          const SizedBox(height: 16),
          _buildLogoText(context),
        ],
      ],
    );

    if (hero) {
      return Hero(
        tag: 'app_logo',
        child: Material(
          color: Colors.transparent,
          child: logo,
        ),
      );
    }

    return logo;
  }

  Widget _buildLogoIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: SleepColors.primary.withValues(alpha: 0.2),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }

  Widget _buildLogoText(BuildContext context) {
    return Text(
      'DreamDrift',
      style: TextStyle(
        fontSize: size * 0.35,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.45;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          SleepColors.primaryLight,
          SleepColors.primary,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw stylized crescent moon
    final path = Path();
    
    // Outer circle
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    
    // Inner circle (to cut out the crescent)
    final innerPath = Path();
    innerPath.addOval(Rect.fromCircle(
      center: Offset(center.dx + radius * 0.35, center.dy - radius * 0.2),
      radius: radius * 0.9,
    ));

    final crescentPath = Path.combine(PathOperation.difference, path, innerPath);

    // Draw moon
    canvas.drawPath(crescentPath, paint);

    // Draw some "drift" sparkles or stars around it
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final random = math.Random(42); // Fixed seed for consistent look
    
    for (int i = 0; i < 5; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = radius * (1.1 + random.nextDouble() * 0.3);
      final starSize = random.nextDouble() * 2.0 + 1.0;
      
      canvas.drawCircle(
        Offset(center.dx + math.cos(angle) * dist, center.dy + math.sin(angle) * dist),
        starSize,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
