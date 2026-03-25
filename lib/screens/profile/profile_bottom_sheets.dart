import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class ProfileBottomSheets {
  static Future<void> showExportDataSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _ExportDataSheet(),
    );
  }

  static Future<void> showTimerSelectionSheet(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentMinutes = auth.profile?.defaultSleepTimer.inMinutes ?? 30;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectionSheet(
        title: 'Default Sleep Timer',
        options: const ['15 minutes', '30 minutes', '45 minutes', '60 minutes'],
        currentSelection: '$currentMinutes minutes',
        onSelected: (val) {
          final mins = int.parse(val.split(' ')[0]);
          if (auth.profile != null) {
            auth.updateProfile(auth.profile!.copyWith(
              defaultSleepTimer: Duration(minutes: mins),
            ));
          }
        },
      ),
    );
  }

  static Future<void> showFadeOutSheet(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentMinutes = auth.profile?.fadeOutDuration.inMinutes ?? 5;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectionSheet(
        title: 'Fade Out Duration',
        options: const ['0 minutes', '1 minute', '5 minutes', '10 minutes'],
        currentSelection: currentMinutes == 0 ? '0 minutes' : (currentMinutes == 1 ? '1 minute' : '$currentMinutes minutes'),
        onSelected: (val) {
          final mins = int.parse(val.split(' ')[0]);
          if (auth.profile != null) {
            auth.updateProfile(auth.profile!.copyWith(
              fadeOutDuration: Duration(minutes: mins),
            ));
          }
        },
      ),
    );
  }
}

class _ExportDataSheet extends StatefulWidget {
  const _ExportDataSheet();

  @override
  State<_ExportDataSheet> createState() => _ExportDataSheetState();
}

class _ExportDataSheetState extends State<_ExportDataSheet> {
  bool _isExporting = true;

  @override
  void initState() {
    super.initState();
    // Simulate export delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SleepColors.background.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          if (_isExporting) ...[
            const CircularProgressIndicator(color: SleepColors.primaryLight),
            const SizedBox(height: 24),
            const Text(
              'Gathering your sleep data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This might take a moment.',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(
              Icons.check_circle_outline,
              color: SleepColors.success,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Export Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your sleep journey has been compiled and is ready for download.',
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SleepColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SelectionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String currentSelection;
  final ValueChanged<String> onSelected;

  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.currentSelection,
    required this.onSelected,
  });

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: SleepColors.background.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(widget.options.length, (index) {
                final option = widget.options[index];
                final isSelected = option == _selected;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : SleepColors.textSecondary,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: SleepColors.primaryLight,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selected = option);
                        widget.onSelected(option);
                        Navigator.pop(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                    ),
                    if (index < widget.options.length - 1)
                      Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                  ],
                );
              }),
            ),
          ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
