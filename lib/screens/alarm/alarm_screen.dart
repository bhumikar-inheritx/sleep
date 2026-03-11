import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/alarm/circular_clock_picker.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(
        title: 'Sleep schedule',
        transparent: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SleepColors.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Consumer<AlarmProvider>(
            builder: (context, alarmProvider, child) {
              if (alarmProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final settings = alarmProvider.settings;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTimeDisplays(context, settings.bedtime, settings.wakeTime),
                    
                    const SizedBox(height: 32),
                    
                    // The Circular Picker
                    Center(
                      child: CircularClockPicker(
                        bedtime: settings.bedtime,
                        wakeTime: settings.wakeTime,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    _buildRepeatDays(context, alarmProvider),
                    
                    const SizedBox(height: 32),
                    
                    _buildAlarmSettings(context, alarmProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplays(BuildContext context, TimeOfDay bedtime, TimeOfDay wakeTime) {
    String formatTime(TimeOfDay time) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('h:mm a').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.bed, color: SleepColors.primary, size: 16),
                   SizedBox(width: 8),
                   Text('Bedtime', style: TextStyle(color: SleepColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatTime(bedtime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Row(
                children: [
                   Icon(Icons.wb_sunny, color: SleepColors.primaryLight, size: 16),
                   SizedBox(width: 8),
                   Text('Wake up', style: TextStyle(color: SleepColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatTime(wakeTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatDays(BuildContext context, AlarmProvider provider) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    // standard DateTime weekday mapping: 1 = Mon ... 7 = Sun.
    // However, the UI expects Sun-Sat (7, 1..6)
    const dayIndices = [7, 1, 2, 3, 4, 5, 6]; 
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repeat Alarm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayId = dayIndices[index];
              final isSelected = provider.settings.repeatDays.contains(dayId);
              
              return GestureDetector(
                onTap: () => provider.toggleRepeatDay(dayId),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : SleepColors.surfaceLight,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected ? SleepColors.background : SleepColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmSettings(BuildContext context, AlarmProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alarm Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.alarm, color: SleepColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Wake-up alarm',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  value: provider.settings.isWakeAlarmEnabled,
                  onChanged: (val) => provider.toggleWakeAlarm(val),
                  activeTrackColor: SleepColors.primaryLight.withValues(alpha: 0.5),
                  activeThumbColor: SleepColors.primaryLight,
                ),
                Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.bedtime, color: SleepColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Bedtime reminder',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  value: provider.settings.isBedtimeReminderEnabled,
                  onChanged: (val) => provider.toggleBedtimeReminder(val),
                  activeTrackColor: SleepColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: SleepColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
