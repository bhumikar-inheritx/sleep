import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _bedtimeReminders = true;
  bool _dailyDigest = false;
  bool _newAudioAlerts = true;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const SleepAppBar(title: 'Notifications'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage your notification preferences',
                  style: TextStyle(
                    color: SleepColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        title: 'Bedtime Reminders',
                        subtitle: 'Get notified when it is time to wind down',
                        value: _bedtimeReminders,
                        onChanged: (val) => setState(() => _bedtimeReminders = val),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'Daily Sleep Digest',
                        subtitle: 'Morning summary of your sleep data',
                        value: _dailyDigest,
                        onChanged: (val) => setState(() => _dailyDigest = val),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'New Audio Alerts',
                        subtitle: 'Be the first to know about new sleep sounds',
                        value: _newAudioAlerts,
                        onChanged: (val) => setState(() => _newAudioAlerts = val),
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'App Updates & Offers',
                        subtitle: 'News, tips and special offers',
                        value: _appUpdates,
                        onChanged: (val) => setState(() => _appUpdates = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SleepColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: SleepColors.primaryLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
