import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/sound_mixer_provider.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  final _controller = TextEditingController();
  bool _isCustom = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final mixerProvider = Provider.of<SoundMixerProvider>(context);

    final options = [
      {'label': '15 Minutes', 'duration': const Duration(minutes: 15)},
      {'label': '30 Minutes', 'duration': const Duration(minutes: 30)},
      {'label': '45 Minutes', 'duration': const Duration(minutes: 45)},
      {'label': '1 Hour', 'duration': const Duration(hours: 1)},
      {
        'label': audioProvider.currentType == AudioContentType.story ? 'End of Chapter' : 'End of Track', 
        'duration': audioProvider.duration - audioProvider.position
      },
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Sleep Timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (audioProvider.isSleepTimerActive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Consumer<AudioPlayerProvider>(
                    builder: (context, audio, _) {
                      final remaining = audio.sleepTimerRemaining ?? Duration.zero;
                      final mins = remaining.inMinutes;
                      final secs = remaining.inSeconds % 60;
                      return Text(
                        'Ending in ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: SleepColors.primaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              if (audioProvider.isSleepTimerActive)
                ListTile(
                  title: const Text('Turn Off Timer', style: TextStyle(color: Colors.redAccent)),
                  leading: const Icon(Icons.timer_off_outlined, color: Colors.redAccent),
                  onTap: () {
                    audioProvider.cancelSleepTimer();
                    mixerProvider.cancelSleepTimer();
                    Navigator.pop(context);
                  },
                ),
              if (!_isCustom) ...[
                ...options.map((opt) => ListTile(
                  title: Text(opt['label'] as String, style: const TextStyle(color: Colors.white)),
                  leading: const Icon(Icons.timer_outlined, color: SleepColors.textSecondary),
                  onTap: () {
                    final dur = opt['duration'] as Duration;
                    if (dur.inSeconds > 0) {
                      audioProvider.setSleepTimer(dur);
                      mixerProvider.setSleepTimer(dur);
                    }
                    Navigator.pop(context);
                  },
                )),
                ListTile(
                  title: const Text('Custom...', style: TextStyle(color: Colors.white)),
                  leading: const Icon(Icons.edit_note, color: SleepColors.textSecondary),
                  onTap: () {
                    setState(() {
                      _isCustom = true;
                    });
                  },
                ),
              ] else 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Minutes',
                            hintStyle: const TextStyle(color: SleepColors.textMuted),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SleepColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final minutes = int.tryParse(_controller.text);
                          if (minutes != null && minutes > 0) {
                            final dur = Duration(minutes: minutes);
                            audioProvider.setSleepTimer(dur);
                            mixerProvider.setSleepTimer(dur);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Set', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void showSleepTimerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: SleepColors.surfaceGlass,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const SleepTimerSheet(),
  );
}
