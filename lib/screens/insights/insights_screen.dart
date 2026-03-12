import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../models/sleep_log.dart';
import '../../providers/sleep_tracker_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../../widgets/insights/sleep_score_ring.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(title: 'Sleep Journey', transparent: true),
      body: SafeArea(
        bottom: false,
        child: Consumer<SleepTrackerProvider>(
          builder: (context, tracker, child) {
            if (tracker.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final logs = tracker.logs;
            if (logs.isEmpty) {
              return const Center(
                child: Text(
                  'No sleep data yet.\nTrack your sleep tonight!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SleepColors.textMuted),
                ),
              );
            }

            final latestLog = logs.first;
            final latestScore = latestLog.qualityRating / 5.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Ring
                  Center(child: SleepScoreRing(percentage: latestScore)),

                  const SizedBox(height: 32),

                  // Quick Recap
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Quick recap',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(context, tracker),

                  const SizedBox(height: 32),

                  // Weekly Chart
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(context, logs),

                  const SizedBox(height: 32),

                  // Sleep Logs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Sleep log',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSleepLogsList(context, logs),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, SleepTrackerProvider tracker) {
    final avgDuration = tracker.averageSleepDuration;
    final avgQuality = tracker.averageSleepQuality;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.nights_stay_outlined,
                        color: SleepColors.primaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Avg Time',
                        style: TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${avgDuration.inHours}h ${avgDuration.inMinutes % 60}m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: SleepColors.primaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Avg Quality',
                        style: TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(avgQuality * 20).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<SleepLog> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    // Prepare data for the last 7 days if available
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));

      // Find log matching this date
      final log = logs
          .where(
            (l) =>
                l.wakeTime.year == targetDate.year &&
                l.wakeTime.month == targetDate.month &&
                l.wakeTime.day == targetDate.day,
          )
          .firstOrNull;

      double hours = 0;
      if (log != null) {
        hours = log.sleepDuration.inMinutes / 60.0;
      }

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: hours,
              width: 24,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [SleepColors.primaryLight, SleepColors.primary],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10, // Max scale
                color: Colors.white.withValues(alpha: 0.1), // Increased opacity
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassCard(
        padding: const EdgeInsets.only(
          top: 32,
          bottom: 16,
          left: 16,
          right: 16,
        ),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = now.subtract(
                        Duration(days: 6 - value.toInt()),
                      );
                      final dayStr = DateFormat('E').format(date); // e.g. Mon
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dayStr,
                          style: const TextStyle(
                            color: SleepColors.textSecondary, // Lightened from textMuted
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Hide left axis
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.1), // Increased opacity for visibility
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepLogsList(BuildContext context, List<SleepLog> logs) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length > 5 ? 5 : logs.length,
      separatorBuilder: (context, index) =>
          const Divider(color: SleepColors.surfaceLight, height: 32),
      itemBuilder: (context, index) {
        final log = logs[index];
        final dayStr = DateFormat('EEE').format(log.wakeTime);
        final bedTimeStr = DateFormat('h:mm a').format(log.bedtime);
        final wakeTimeStr = DateFormat('h:mm a').format(log.wakeTime);

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last sleep ($dayStr)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bedTimeStr - $wakeTimeStr',
                    style: const TextStyle(
                      color: SleepColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  log.formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(log.qualityRating / 5.0 * 100).toInt()}% • ${log.mood ?? 'Ok'}',
                  style: const TextStyle(
                    color: SleepColors.primaryLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
