import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/common/sleep_app_bar.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isActive = false;
  String _currentPhase = 'Ready';

  // 4-7-8 Breathing settings
  final int _inhale = 4;
  final int _hold = 7;
  final int _exhale = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Initial inhale duration
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.addStatusListener((status) {
      if (!_isActive) return;

      if (status == AnimationStatus.completed) {
        // Finished inhaling, now hold
        setState(() {
          _currentPhase = 'Hold';
        });
        _handleHoldPhase();
      } else if (status == AnimationStatus.dismissed) {
        // Finished exhaling, start inhaling again
        setState(() {
          _currentPhase = 'Inhale';
        });
        _controller.duration = Duration(seconds: _inhale);
        _controller.forward();
      }
    });
  }

  void _handleHoldPhase() async {
    // We don't animate the circle during hold
    await Future.delayed(Duration(seconds: _hold));
    if (!mounted || !_isActive) return;

    // Start exhale
    setState(() {
      _currentPhase = 'Exhale';
    });
    _controller.duration = Duration(seconds: _exhale);
    _controller.reverse();
  }

  void _toggleExercise() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _currentPhase = 'Inhale';
        _controller.duration = Duration(seconds: _inhale);
        _controller.forward();
      } else {
        _currentPhase = 'Paused';
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(title: '4-7-8 Breathing', transparent: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SleepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // The Breathing Circle
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive size: 80% of width or max 300
                    final size = (MediaQuery.of(context).size.width * 0.8).clamp(200.0, 300.0);
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Inner animated glow
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: size * 0.85,
                                  height: size * 0.85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: SleepColors.primary.withValues(
                                      alpha: _opacityAnimation.value,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: SleepColors.primaryLight.withValues(
                                          alpha: _opacityAnimation.value * 0.5,
                                        ),
                                        blurRadius: 40 * _scaleAnimation.value,
                                        spreadRadius: 20 * _scaleAnimation.value,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Center Text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPhase,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size * 0.1, // Responsive font size
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Breathe in for 4s, hold for 7s, exhale for 8s. This technique helps calm the nervous system before sleep.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SleepColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Start/Stop Button
              GestureDetector(
                onTap: _toggleExercise,
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 48),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    color: _isActive ? Colors.transparent : SleepColors.primary,
                  ),
                  child: Center(
                    child: Icon(
                      _isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
