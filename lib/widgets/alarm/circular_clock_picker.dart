import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/colors.dart';

class CircularClockPicker extends StatelessWidget {
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final double size;

  const CircularClockPicker({
    super.key,
    required this.bedtime,
    required this.wakeTime,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate sleep duration specifically for the display
    var bHour = bedtime.hour;
    var bMin = bedtime.minute;
    var wHour = wakeTime.hour;
    var wMin = wakeTime.minute;

    if (wHour < bHour || (wHour == bHour && wMin < bMin)) {
      wHour += 24;
    }

    final totalBedMinutes = bHour * 60 + bMin;
    final totalWakeMinutes = wHour * 60 + wMin;
    final durationMinutes = totalWakeMinutes - totalBedMinutes;
    final duration = Duration(minutes: durationMinutes);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ClockPainter(bedtime: bedtime, wakeTime: wakeTime),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${duration.inHours} hr ${(duration.inMinutes % 60).toString().padLeft(2, '0')} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sleep duration',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;

  _ClockPainter({required this.bedtime, required this.wakeTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 40) / 2;

    // 1. Draw Dial Background
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Calculate angles
    // 0 degrees is 3 o'clock. We want 12 o'clock to be top (-90 degrees / -pi/2).
    // The dial represents 24 hours.
    double timeToAngle(TimeOfDay time) {
      final totalMinutes = time.hour * 60 + time.minute;
      final percentage = totalMinutes / (24 * 60);
      // Maps to 0 -> 2pi, starting from top
      return (percentage * 2 * pi) - (pi / 2);
    }

    final startAngle = timeToAngle(bedtime);
    double endAngle = timeToAngle(wakeTime);

    // If waketime is "before" bedtime on the dial, add 2pi
    if (endAngle < startAngle) {
      endAngle += 2 * pi;
    }
    final sweepAngle = endAngle - startAngle;

    // 3. Draw Arc
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [SleepColors.primary, SleepColors.primaryLight],
        startAngle: 0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // 4. Draw Handles (Icons)
    void drawHandle(double angle, IconData icon, Color color) {
      final handleRadius = radius;
      final x = center.dx + handleRadius * cos(angle);
      final y = center.dy + handleRadius * sin(angle);

      final handleCenter = Offset(x, y);

      // White circle background
      canvas.drawCircle(handleCenter, 14, Paint()..color = Colors.white);

      // Icon (we have to use a TextPainter to draw the Material icon)
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          handleCenter.dx - textPainter.width / 2,
          handleCenter.dy - textPainter.height / 2,
        ),
      );
    }

    drawHandle(startAngle, Icons.bed, SleepColors.primary);
    drawHandle(endAngle, Icons.wb_sunny, SleepColors.primaryLight);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.bedtime != bedtime || oldDelegate.wakeTime != wakeTime;
  }
}
