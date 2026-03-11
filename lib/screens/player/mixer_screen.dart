import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/soundscape.dart';
import '../../providers/content_provider.dart';
import '../../providers/sound_mixer_provider.dart';
import '../../widgets/common/glass_card.dart';

class MixerScreen extends StatelessWidget {
  const MixerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SleepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Your Mix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<SoundMixerProvider>(
                      builder: (context, mixer, child) {
                        return TextButton(
                          onPressed: () => mixer.clearMix(),
                          child: const Text('Clear', style: TextStyle(color: SleepColors.primaryLight)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Active Sounds List
              Expanded(
                child: Consumer2<SoundMixerProvider, ContentProvider>(
                  builder: (context, mixer, content, child) {
                    final sounds = content.sounds;
                    final activeSounds = sounds.where((s) => mixer.isSoundActive(s.id)).toList();
                    
                    if (activeSounds.isEmpty) {
                      return const Center(
                        child: Text(
                          'No sounds in your mix yet.',
                          style: TextStyle(color: SleepColors.textMuted),
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: activeSounds.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final sound = activeSounds[index];
                        return _MixerSliderCard(sound: sound);
                      },
                    );
                  },
                ),
              ),
              
              // Bottom Master Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Consumer<SoundMixerProvider>(
                  builder: (context, mixer, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                        GestureDetector(
                          onTap: () {
                            if (mixer.isPlaying) {
                              mixer.pauseAll();
                            } else {
                              mixer.playAll();
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SleepColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: SleepColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              mixer.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                          onPressed: () {}, // Save mix
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MixerSliderCard extends StatelessWidget {
  final Soundscape sound;

  const _MixerSliderCard({required this.sound});

  IconData _getIconForName(String name) {
    switch (name) {
      case 'rain_heavy': return Icons.water_drop;
      case 'thunder': return Icons.flash_on;
      case 'waves': return Icons.waves;
      case 'wind': return Icons.air;
      case 'birds': return Icons.cruelty_free;
      case 'fire': return Icons.local_fire_department;
      default: return Icons.music_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Consumer<SoundMixerProvider>(
        builder: (context, mixer, child) {
          final volume = mixer.getVolume(sound.id);
          
          return Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SleepColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForName(sound.iconName), color: SleepColors.primaryLight),
              ),
              const SizedBox(width: 16),
              
              // Slider and Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) {
                          mixer.setVolume(sound.id, val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove Button
              IconButton(
                icon: const Icon(Icons.close, color: SleepColors.textMuted, size: 20),
                onPressed: () => mixer.toggleSound(sound),
              ),
            ],
          );
        },
      ),
    );
  }
}
