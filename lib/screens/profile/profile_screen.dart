import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';

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
              const SizedBox(height: 32),
              _buildSettingsGroup(
                context,
                title: 'Account',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.download_outlined,
                    title: 'Export Sleep Data',
                    onTap: () {},
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
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.palette_outlined,
                    title: 'App Theme',
                    trailing: const Text(
                      'Dark',
                      style: TextStyle(color: SleepColors.textMuted),
                    ),
                    onTap: () {},
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
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.volume_down_outlined,
                    title: 'Fade Out Duration',
                    trailing: const Text(
                      '5 min',
                      style: TextStyle(color: SleepColors.textMuted),
                    ),
                    onTap: () {},
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
        final initials = auth.userName?.isNotEmpty == true ? auth.userName![0].toUpperCase() : 'S';
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
                    Text(
                      auth.userEmail ?? 'user@example.com',
                      style: const TextStyle(
                        color: SleepColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
