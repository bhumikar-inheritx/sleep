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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.nights_stay_rounded,
            color: SleepColors.primaryLight,
          ),
        ),
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
      ),
    );
  }
}
