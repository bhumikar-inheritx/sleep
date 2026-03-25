import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../models/routine.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';

class RoutineExecutionScreen extends StatefulWidget {
  const RoutineExecutionScreen({super.key});

  @override
  State<RoutineExecutionScreen> createState() => _RoutineExecutionScreenState();
}

class _RoutineExecutionScreenState extends State<RoutineExecutionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, routine, child) {
        if (!routine.isActive) {
          return const Scaffold(backgroundColor: SleepColors.background);
        }

        if (routine.isCompleted) {
          return Scaffold(
            backgroundColor: SleepColors.background,
            body: _buildCompletionScreen(context, routine),
          );
        }

        final step = routine.currentStep;
        if (step == null)
          return const Scaffold(backgroundColor: SleepColors.background);

        return AppBackground(
          backgroundImage: 'assets/images/start_ritual_background.png',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                _buildAnimatedBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, routine),
                      const Spacer(),
                      _buildStepContent(step),
                      const SizedBox(height: 48),
                      _buildTimer(routine),
                      const Spacer(),
                      _buildProgressIndicator(routine),
                      const SizedBox(height: 32),
                      _buildControls(routine),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Container(
            width: 300 + (50 * _breathingController.value),
            height: 300 + (50 * _breathingController.value),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SleepColors.primary.withValues(
                    alpha: 0.1 * _breathingController.value,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RoutineProvider routine) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              routine.stopRoutine();
              Navigator.pop(context);
            },
          ),
          Text(
            routine.currentRoutine?.name ?? 'Wind-Down',
            style: const TextStyle(
              color: SleepColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildStepContent(RoutineStep step) {
    return Column(
      children: [
        _getStepLargeIcon(step.type),
        const SizedBox(height: 24),
        Text(
          step.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getStepDescription(step.type),
          style: const TextStyle(
            color: SleepColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _getStepLargeIcon(RoutineStepType type) {
    IconData icon;
    Color color;
    switch (type) {
      case RoutineStepType.journal:
        icon = Icons.edit_note;
        color = Colors.blueAccent;
      case RoutineStepType.meditation:
        icon = Icons.self_improvement;
        color = Colors.tealAccent;
      case RoutineStepType.music:
        icon = Icons.music_note;
        color = Colors.purpleAccent;
      case RoutineStepType.soundscape:
        icon = Icons.water_drop;
        color = Colors.lightBlueAccent;
      case RoutineStepType.breathing:
        icon = Icons.air;
        color = Colors.greenAccent;
    }
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 64),
    );
  }

  String _getStepDescription(RoutineStepType type) {
    switch (type) {
      case RoutineStepType.journal:
        return 'Take a moment to write down\nthree things you are grateful for.';
      case RoutineStepType.meditation:
        return 'Focus on your breath and let\ngo of any tension in your body.';
      case RoutineStepType.music:
        return 'Listen to the soothing melodies\nand prepare for sleep.';
      case RoutineStepType.soundscape:
        return 'Immerse yourself in the ambient\nsounds of nature.';
      case RoutineStepType.breathing:
        return 'Follow the gentle rhythm and\nslow down your breathing.';
    }
  }

  Widget _buildTimer(RoutineProvider routine) {
    return Text(
      _formatDuration(routine.remainingTime),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 72,
        fontWeight: FontWeight.w200,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildProgressIndicator(RoutineProvider routine) {
    final steps = routine.currentRoutine?.steps ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        final isActive = index == routine.currentStepIndex;
        final isCompleted = index < routine.currentStepIndex;
        return Container(
          width: 24,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? SleepColors.primaryLight
                : (isCompleted
                      ? SleepColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildControls(RoutineProvider routine) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Colors.white,
            size: 36,
          ),
          onPressed: routine.currentStepIndex > 0 ? routine.previousStep : null,
        ),
        GestureDetector(
          onTap: () {
            // Toggle pause logic could be added here
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
            size: 36,
          ),
          onPressed: routine.nextStep,
        ),
      ],
    );
  }

  Widget _buildCompletionScreen(BuildContext context, RoutineProvider routine) {
    return AppBackground(
      backgroundImage: 'assets/images/start_ritual_background.png',
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: SleepColors.primaryLight,
                    size: 120,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Ritual Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You are now ready for a deep and\nrestful sleep. Good night!',
              style: TextStyle(color: SleepColors.textSecondary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: GlassCard(
                onTap: () {
                  routine.stopRoutine();
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: Text(
                    'FINISH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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
