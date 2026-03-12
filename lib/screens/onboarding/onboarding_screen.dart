import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/alarm/circular_clock_picker.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/gradient_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Consumer<OnboardingProvider>(
            builder: (context, provider, child) {
              final isVibrant = provider.currentPage == 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: isVibrant
                    ? Colors.black.withValues(
                        alpha: 0.3,
                      ) // Overlay for vibrancy
                    : Colors.transparent,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Progress Indicator (Skip on first and last page)
                      if (provider.currentPage > 0 && provider.currentPage < 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => provider.previousPage(),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: provider.currentPage / 5,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  color: SleepColors.primaryLight,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance for back button
                            ],
                          ),
                        )
                      else
                        const SizedBox(
                          height: 16,
                        ), // Minimal spacing when progress not shown

                      Expanded(
                        child: PageView(
                          controller: provider.pageController,
                          physics:
                              const NeverScrollableScrollPhysics(), // Only buttons advance
                          onPageChanged: provider.setPage,
                          children: [
                            _buildWelcomePage(context, provider),
                            _buildGoalsPage(context, provider),
                            _buildChallengesPage(context, provider),
                            _buildContentPage(context, provider),
                            _buildBedtimePage(context, provider),
                            _buildCompletePage(context, provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, OnboardingProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              56, // Account for Progress + SafeArea
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Centered Illustration with soft glow
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SleepColors.primaryLight.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/onboarding_moon.png',
                  height: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.bedtime,
                    size: 100,
                    color: SleepColors.primaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Better sleep\nstarts tonight',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Answer a few questions to personalize your sleep experience.',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48), // Spacing instead of Spacer
            GradientButton(
              text: 'Get Started',
              onPressed: () => provider.nextPage(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionPage({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onToggle,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: SleepColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selectedOptions.contains(option);
                return _buildPill(option, isSelected, () => onToggle(option));
              },
            ),
          ),
          GradientButton(
            text: 'Continue',
            onPressed: selectedOptions.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? SleepColors.primary.withValues(alpha: 0.2)
              : SleepColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? SleepColors.primaryLight
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : SleepColors.textSecondary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: SleepColors.primaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage(BuildContext context, OnboardingProvider provider) {
    return _buildSelectionPage(
      context: context,
      title: "What's your sleep goal?",
      subtitle: "Select all that apply",
      options: [
        "Fall asleep faster",
        "Sleep deeper",
        "Wake refreshed",
        "Build a routine",
      ],
      selectedOptions: provider.sleepGoals,
      onToggle: provider.toggleGoal,
      onNext: provider.nextPage,
    );
  }

  Widget _buildChallengesPage(
    BuildContext context,
    OnboardingProvider provider,
  ) {
    return _buildSelectionPage(
      context: context,
      title: "What keeps you up?",
      subtitle: "Select your main challenges",
      options: [
        "Racing thoughts",
        "Noise",
        "Stress & Anxiety",
        "Screen time",
        "Irregular schedule",
      ],
      selectedOptions: provider.sleepChallenges,
      onToggle: provider.toggleChallenge,
      onNext: provider.nextPage,
    );
  }

  Widget _buildContentPage(BuildContext context, OnboardingProvider provider) {
    return _buildSelectionPage(
      context: context,
      title: "What do you like listening to?",
      subtitle: "We'll suggest these tonight",
      options: [
        "Sleep Stories",
        "Nature Soundscapes",
        "Ambient Music",
        "Breathing Exercises",
      ],
      selectedOptions: provider.preferredContent,
      onToggle: provider.toggleContent,
      onNext: provider.nextPage,
    );
  }

  Widget _buildBedtimePage(BuildContext context, OnboardingProvider provider) {
    // Determine a dummy waketime for the picker (say 8 hours later)
    final bTime = provider.targetBedtime;
    final wTime = TimeOfDay(hour: (bTime.hour + 8) % 24, minute: bTime.minute);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Set your target bedtime",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll remind you to wind down.",
            style: TextStyle(color: SleepColors.textSecondary, fontSize: 16),
          ),
          const Spacer(),
          Center(
            child: CircularClockPicker(
              bedtime: provider.targetBedtime,
              wakeTime: wTime,
            ),
          ),
          // Simple time selection buttons to update state (alternative to dragging which isn't implemented in the static widget)
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.schedule, color: Colors.white),
                label: Text(
                  "${bTime.hour > 12
                      ? bTime.hour - 12
                      : bTime.hour == 0
                      ? 12
                      : bTime.hour}:${bTime.minute.toString().padLeft(2, '0')} ${bTime.hour >= 12 ? 'PM' : 'AM'}",
                  style: const TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SleepColors.primaryLight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: provider.targetBedtime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: SleepColors.primaryLight,
                            surface: SleepColors.surface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) provider.setBedtime(time);
                },
              ),
            ],
          ),
          const Spacer(),
          GradientButton(text: 'Continue', onPressed: provider.nextPage),
        ],
      ),
    );
  }

  Widget _buildCompletePage(BuildContext context, OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SleepColors.primaryLight.withValues(alpha: 0.2),
            ),
            child: const Center(
              child: Icon(
                Icons.done_all,
                size: 60,
                color: SleepColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            "You're all set!",
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "We've personalized your night flow.\nRest easy.",
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          GradientButton(
            text: 'Start Exploring',
            onPressed: () async {
              await provider.completeOnboarding();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.signup);
              }
            },
          ),
        ],
      ),
    );
  }
}
