import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../models/soundscape.dart';
import '../../providers/content_provider.dart';
import '../../providers/sound_mixer_provider.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../player/mixer_screen.dart';

class SoundscapesScreen extends StatefulWidget {
  const SoundscapesScreen({super.key});

  @override
  State<SoundscapesScreen> createState() => _SoundscapesScreenState();
}

class _SoundscapesScreenState extends State<SoundscapesScreen> {
  // Use categories from constants
  final List<String> _categories = AppConstants.soundCategories;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(
        title: 'Soundscapes',
        transparent: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: SleepColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCategorySelector(),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<ContentProvider>(
                  builder: (context, contentProvider, child) {
                    if (contentProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: SleepColors.primary));
                    }

                    List<Soundscape> sounds = contentProvider.sounds;
                    if (_selectedCategory != 'All') {
                      sounds = sounds.where((s) => s.category == _selectedCategory).toList();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: sounds.length,
                      itemBuilder: (context, index) {
                        return _SoundIcon(sound: sounds[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<SoundMixerProvider>(
        builder: (context, mixer, child) {
          if (!mixer.isPlaying) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MixerScreen()),
              );
            },
            backgroundColor: SleepColors.primary,
            icon: const Icon(Icons.tune, color: Colors.white),
            label: const Text('Open Mixer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? SleepColors.primary : SleepColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : SleepColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SoundIcon extends StatelessWidget {
  final Soundscape sound;

  const _SoundIcon({required this.sound});

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
    return Consumer<SoundMixerProvider>(
      builder: (context, mixer, child) {
        final isActive = mixer.isSoundActive(sound.id);

        return GestureDetector(
          onTap: () => mixer.toggleSound(sound),
          child: Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? SleepColors.primary : SleepColors.surfaceLight,
                    border: isActive 
                        ? Border.all(color: SleepColors.primaryLight, width: 2)
                        : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: SleepColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForName(sound.iconName),
                      color: isActive ? Colors.white : SleepColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sound.name,
                style: TextStyle(
                  color: isActive ? Colors.white : SleepColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
