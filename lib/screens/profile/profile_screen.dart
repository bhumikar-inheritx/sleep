
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';

import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_bottom_sheets.dart';
import '../../services/health_service.dart';
import '../../providers/premium_provider.dart';
import '../premium/paywall_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(title: 'Profile', transparent: true),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // Space for nav bar
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildBadges(context),
              const SizedBox(height: 32),
              _buildSettingsGroup(
                context,
                title: 'Account',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.download_outlined,
                    title: 'Export Sleep Data',
                    onTap: () {
                      ProfileBottomSheets.showExportDataSheet(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsGroup(
                context,
                title: 'Preferences',
                items: [
                  _SettingsItem(
                    icon: Icons.alarm,
                    title: 'Smart Alarm Settings',
                    onTap: () {
                      // In a real app, this might be a bottom sheet or
                      // full screen navigation back to Alarm tab or specific settings
                      Navigator.pushNamed(context, '/alarm');
                    },
                    ),
                  _SettingsItem(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Health Platform Sync',
                    trailing: const Text(
                      'HealthKit / Fit',
                      style: TextStyle(color: SleepColors.textMuted, fontSize: 12),
                    ),
                    onTap: () async {
                      final success = await HealthService.requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                                ? 'Health sync activated!' 
                                : 'Permission denied or not supported.'),
                            backgroundColor: success ? SleepColors.primary : Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsGroup(
                context,
                title: 'Audio Settings',
                items: [
                  _SettingsItem(
                    icon: Icons.timer_outlined,
                    title: 'Default Sleep Timer',
                    trailing: const Text(
                      '30 min',
                      style: TextStyle(color: SleepColors.textMuted),
                    ),
                    onTap: () {
                      ProfileBottomSheets.showTimerSelectionSheet(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.volume_down_outlined,
                    title: 'Fade Out Duration',
                    trailing: const Text(
                      '5 min',
                      style: TextStyle(color: SleepColors.textMuted),
                    ),
                    onTap: () {
                      ProfileBottomSheets.showFadeOutSheet(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    trailing: Consumer<LocaleProvider>(
                      builder: (context, locale, _) => Text(
                        locale.locale.languageCode.toUpperCase(),
                        style: const TextStyle(color: SleepColors.textMuted),
                      ),
                    ),
                    onTap: () {
                      _showLanguageSheet(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final streak = auth.profile?.streakDays ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Row(
            children: [
              const AppLogo(size: 72, showText: false, hero: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userName ?? 'Dreamer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$streak Day Streak',
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildPremiumBanner(context),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SleepColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            final currentLocale = localeProvider.locale;
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _languageOption(
                    context, 
                    'English', 
                    const Locale('en'), 
                    currentLocale == const Locale('en'),
                    localeProvider,
                  ),
                  _languageOption(
                    context, 
                    'Español', 
                    const Locale('es'), 
                    currentLocale == const Locale('es'),
                    localeProvider,
                  ),
                  _languageOption(
                    context, 
                    'Hindi', 
                    const Locale('hi'), 
                    currentLocale == const Locale('hi'),
                    localeProvider,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _languageOption(
    BuildContext context, 
    String label, 
    Locale locale, 
    bool isSelected,
    LocaleProvider provider,
  ) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: SleepColors.primaryLight) 
          : null,
      onTap: () {
        provider.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (premium.isPremium) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaywallScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'GO PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Achievements',
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _BadgeIcon(
                icon: Icons.auto_awesome,
                label: 'Early Bird',
                isUnlocked: true,
                color: Colors.amber,
              ),
              _BadgeIcon(
                icon: Icons.nightlight_round,
                label: 'Night Owl',
                isUnlocked: true,
                color: Colors.purpleAccent,
              ),
              _BadgeIcon(
                icon: Icons.timer,
                label: '7 Day Streak',
                isUnlocked: false,
                color: Colors.orangeAccent,
              ),
              _BadgeIcon(
                icon: Icons.favorite,
                label: 'Content Lover',
                isUnlocked: true,
                color: Colors.redAccent,
              ),
              _BadgeIcon(
                icon: Icons.self_improvement,
                label: 'Zen Master',
                isUnlocked: false,
                color: Colors.tealAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        item.icon,
                        color: SleepColors.primaryLight,
                        size: 22,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.trailing != null) ...[
                            item.trailing!,
                            const SizedBox(width: 8),
                          ],
                          const Icon(
                            Icons.chevron_right,
                            color: SleepColors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: item.onTap,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    if (index < items.length - 1)
                      Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                        indent: 56, // Align with text
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


class _SettingsItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUnlocked;
  final Color color;

  const _BadgeIcon({
    required this.icon,
    required this.label,
    required this.isUnlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.15)
                  : SleepColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? color.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.05),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : SleepColors.textMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isUnlocked ? Colors.white : SleepColors.textMuted,
              fontSize: 10,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
