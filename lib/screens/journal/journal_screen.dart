import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../config/colors.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const SleepAppBar(title: 'Sleep Journal', transparent: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ).copyWith(bottom: 100),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildAddEntryCard(context),
              const SizedBox(height: 32),
              const Text(
                'Recent Entries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How did you sleep?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your sleep patterns to understand what helps you rest better.',
          style: TextStyle(
            color: SleepColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddEntryCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        _showLogEntrySheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SleepColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: SleepColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log Last Night\'s Sleep',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: SleepColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No entries yet',
              style: TextStyle(color: SleepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SleepColors
          .surfaceLight, // Keep default slightly darker or use surface
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _LogEntrySheet();
      },
    );
  }
}

class _LogEntrySheet extends StatefulWidget {
  const _LogEntrySheet();

  @override
  State<_LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends State<_LogEntrySheet> {
  int _selectedMood = -1;
  double _sleepQuality = 5.0;
  final TextEditingController _notesController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😭', 'label': 'Awful'},
    {'emoji': '😢', 'label': 'Bad'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '🤩', 'label': 'Great'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _listen() async {
    debugPrint('Mic tapped, _isListening: $_isListening');
    if (!_isListening) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requesting permissions...'), duration: Duration(seconds: 1)),
        );
      }

      try {
        // Request microphone permission explicitly
        PermissionStatus micStatus = await Permission.microphone.request();
        debugPrint('Microphone status: $micStatus');

        if (micStatus != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  micStatus == PermissionStatus.permanentlyDenied 
                    ? 'Microphone permission is permanently denied.' 
                    : 'Microphone permission denied.',
                ),
                backgroundColor: Colors.redAccent,
                action: micStatus == PermissionStatus.permanentlyDenied ? SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                ) : null,
              ),
            );
          }
          return;
        }

        // We will skip the explicit Permission.speech check here because it's reporting permanentlyDenied
        // and instead let _speech.initialize() handle it or report its own available status.
        debugPrint('Skipping explicit speech permission check, proceeding to initialization...');
      } catch (e) {
        debugPrint('Error during permission/session setup: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuring audio session...'), duration: Duration(seconds: 1)),
        );
      }

      // Configure audio session for speech recognition
      try {
        final session = await AudioSession.instance;
        await session.configure(
          AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionCategoryOptions:
                AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
            avAudioSessionMode: AVAudioSessionMode.measurement,
            avAudioSessionRouteSharingPolicy:
                AVAudioSessionRouteSharingPolicy.defaultPolicy,
          ),
        );
        debugPrint('Audio session configured');
      } catch (e) {
        debugPrint("Error configuring audio session: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio Session Error: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initializing speech engine...'), duration: Duration(seconds: 1)),
        );
      }

      try {
        bool available = await _speech.initialize(
          onStatus: (val) {
            debugPrint('Speech Status: $val');
            if (val == 'done' || val == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
          onError: (val) {
            debugPrint('Speech Error: ${val.errorMsg}');
            if (mounted) {
              setState(() => _isListening = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Speech Error: ${val.errorMsg}'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
        );

        debugPrint('Speech available: $available');

        if (available) {
          if (mounted) setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              if (mounted) {
                setState(() {
                  _lastWords = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _notesController.text = val.recognizedWords;
                  }
                });
              }
            },
            listenMode: stt.ListenMode.dictation,
            cancelOnError: true,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Speech recognition is not available on this device.',
                ),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error initializing speech: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Init Error: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isListening = false);
      _speech.stop();
      debugPrint('Speech stopped manually');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Sleep',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Mood Selector
              const Text(
                'How are you feeling this morning?',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_moods.length, (index) {
                  final isSelected = _selectedMood == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SleepColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? SleepColors.primaryLight
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _moods[index]['emoji'] as String,
                        style: TextStyle(fontSize: isSelected ? 32 : 28),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Quality Slider
              const Text(
                'Sleep Quality',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Poor',
                    style: TextStyle(
                      color: SleepColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: SleepColors.primaryLight,
                        inactiveTrackColor: SleepColors.surfaceGlass,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _sleepQuality,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _sleepQuality.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _sleepQuality = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const Text(
                    'Excellent',
                    style: TextStyle(
                      color: SleepColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Did you wake up during the night? Have any dreams?',
                  hintStyle: const TextStyle(color: SleepColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? Colors.redAccent
                          : SleepColors.primaryLight,
                    ),
                    onPressed: _listen,
                  ),
                  filled: true,
                  fillColor: SleepColors.surfaceGlass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SleepColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _selectedMood == -1
                      ? null
                      : () {
                          // Save logic would go here
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sleep logged successfully!'),
                            ),
                          );
                        },
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
