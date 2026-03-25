import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppBackground extends StatefulWidget {
  final Widget child;
  final String? backgroundImage;

  const AppBackground({
    super.key,
    required this.child,
    this.backgroundImage,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];
  final int _starCount = 40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Initialize stars with random positions and twinkling offsets
    final random = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        twinkleSpeed: random.nextDouble() * 2.0 + 1.0,
        twinkleOffset: random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            widget.backgroundImage ?? 'assets/images/background_gradient.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // Dark Overlay for legibility
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ),
        // Twinkling Stars Layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarPainter(
                  stars: _stars,
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double twinkleOffset;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animationValue;

  _StarPainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      // Calculate opacity based on sine wave for twinkling
      final opacity = (math.sin(animationValue * math.pi * 2 * star.twinkleSpeed + star.twinkleOffset) + 1) / 2;
      
      paint.color = Colors.white.withValues(alpha: opacity * 0.6);
      
      final position = Offset(star.x * size.width, star.y * size.height);
      canvas.drawCircle(position, star.size, paint);
      
      // Add a tiny glow to larger stars
      if (star.size > 1.5) {
        paint.color = Colors.white.withValues(alpha: opacity * 0.2);
        canvas.drawCircle(position, star.size * 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}
