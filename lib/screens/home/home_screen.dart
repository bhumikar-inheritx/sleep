import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/meditation.dart';
import '../../models/sleep_story.dart';
import '../../models/sleep_track.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/premium_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../screens/player/meditation_player_screen.dart';
import '../../screens/player/music_player_screen.dart';
import '../../screens/player/story_player_screen.dart';
import '../../screens/routine/routine_builder_screen.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';
import '../premium/paywall_screen.dart';

class _RecommendationCard extends StatelessWidget {
  final dynamic item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subtitle = '';
    String image = '';

    if (item is SleepStory) {
      title = item.title;
      subtitle = item.category;
      image = item.imageUrl;
    } else if (item is SleepTrack) {
      title = item.title;
      subtitle = item.artist;
      image = item.imageUrl;
    } else if (item is Meditation) {
      title = item.title;
      subtitle = item.instructor;
      image = item.imageUrl;
    }

    return GestureDetector(
      onTap: () {
        if (item is SleepStory) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryPlayerScreen(story: item),
            ),
          );
        } else if (item is SleepTrack) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicPlayerScreen(track: item),
            ),
          );
        } else if (item is Meditation) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeditationPlayerScreen(meditation: item),
            ),
          );
        }
      },
      child: GlassCard(
        padding: EdgeInsets.zero,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Image.asset(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: SleepColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const SleepAppBar(
        transparent: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, locale, _) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 100,
            ), // Space for bottom nav/player
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(context, locale),
                const SizedBox(height: 24),
                _buildPremiumBanner(context),
                const SizedBox(height: 24),
                _buildTonightRecommendation(context),
                const SizedBox(height: 24),
                _buildRitualCard(context),
                const SizedBox(height: 32),
                _buildQuickActions(context),
                const SizedBox(height: 32),
                _buildMadeForYou(context),
                const SizedBox(height: 32),
                _buildFavoritesSection(context),
                const SizedBox(height: 32),
                _buildRecentSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, LocaleProvider locale) {
    final auth = Provider.of<AuthProvider>(context);
    final streak = auth.profile?.streakDays ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.translate('good_evening'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  locale.translate('ready_to_wind_down'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SleepColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SleepColors.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (premium.isPremium) return const SizedBox.shrink();

        return _PulseBanner(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaywallScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildMadeForYou(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, recommendation, _) {
        final items = recommendation.personalizedPicks;
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Made For You',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _RecommendationCard(item: items[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openPlayer(BuildContext context, dynamic item) {
    if (item is SleepStory) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoryPlayerScreen(story: item)),
      );
    } else if (item is SleepTrack) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPlayerScreen(track: item)),
      );
    } else if (item is Meditation) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeditationPlayerScreen(meditation: item),
        ),
      );
    }
  }

  String _getItemTitle(dynamic item) {
    if (item is SleepStory) return item.title;
    if (item is SleepTrack) return item.title;
    if (item is Meditation) return item.title;
    return '';
  }

  String _getItemSubtitle(dynamic item) {
    if (item is SleepStory) return item.category;
    if (item is SleepTrack) return item.artist;
    if (item is Meditation) return item.instructor;
    return '';
  }

  String _getItemImage(dynamic item) {
    if (item is SleepStory) return item.imageUrl;
    if (item is SleepTrack) return item.imageUrl;
    if (item is Meditation) return item.imageUrl;
    return 'assets/images/placeholder_cover.png';
  }

  Widget _buildTonightRecommendation(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, recommendation, child) {
        final highlights = recommendation.tonightHighlights;
        if (highlights.isEmpty) return const SizedBox.shrink();

        final item = highlights.first;
        final title = _getItemTitle(item);
        final subtitle = _getItemSubtitle(item);
        final locale = Provider.of<LocaleProvider>(
          context,
        ); // Added locale provider

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            onTap: () => _openPlayer(context, item),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: SleepColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          locale.translate('tonights_pick'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(_getItemImage(item)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: SleepColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRitualCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final routine = auth.profile?.windDownRoutine;
        if (routine == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoutineBuilderScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SleepColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color: SleepColors.primaryLight,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nightly Ritual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${routine.steps.length} steps to better sleep',
                        style: const TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: SleepColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.book_outlined,
        'title': 'Stories',
        'route': AppRoutes.stories,
      },
      {
        'icon': Icons.water_drop_outlined,
        'title': 'Sounds',
        'route': AppRoutes.soundscapes,
      },
      {
        'icon': Icons.music_note_outlined,
        'title': 'Music',
        'route': AppRoutes.music,
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Breathe',
        'route': AppRoutes.breathingExercise,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Explore', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((action) {
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, action['route'] as String),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: SleepColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: SleepColors.primaryLight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: const TextStyle(
                        color: SleepColors
                            .textPrimary, // Changed from Secondary to Primary for visibility
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    return Consumer2<AuthProvider, ContentProvider>(
      builder: (context, auth, content, child) {
        final favorites = auth.profile?.favorites ?? [];
        if (favorites.isEmpty) return const SizedBox.shrink();

        // Get favorite items from ContentProvider
        final favoriteItems = <dynamic>[];
        for (var id in favorites) {
          try {
            final story = content.stories.firstWhere((s) => s.id == id);
            favoriteItems.add(story);
            continue;
          } catch (_) {}
          try {
            final track = content.music.firstWhere((t) => t.id == id);
            favoriteItems.add(track);
          } catch (_) {}
        }

        if (favoriteItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: favoriteItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = favoriteItems[index];
                  final isStory = item is SleepStory;
                  return GestureDetector(
                    onTap: () {
                      if (isStory) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoryPlayerScreen(story: item),
                          ),
                        );
                      } else if (item is SleepTrack) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MusicPlayerScreen(track: item),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: SleepColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                isStory
                                    ? item.imageUrl
                                    : (item as SleepTrack).imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: SleepColors.surfaceLight),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(color: Colors.black45),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => auth.toggleFavorite(
                                  isStory ? item.id : (item as SleepTrack).id,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    isStory
                                        ? item.title
                                        : (item as SleepTrack).title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isStory ? 'Story' : 'Music',
                                    style: TextStyle(
                                      color: SleepColors.textPrimary.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Played',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: SleepColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 3, // Placeholder count
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                decoration: BoxDecoration(
                  color: SleepColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/placeholder_cover.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: SleepColors.surfaceLight),
                        ),
                      ),
                      Positioned.fill(child: Container(color: Colors.black45)),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Rainy Forest',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Soundscape',
                              style: TextStyle(
                                color: SleepColors.textPrimary.withValues(
                                  alpha: 0.7,
                                ), // Increased visibility
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PulseBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _PulseBanner({required this.onTap});

  @override
  State<_PulseBanner> createState() => _PulseBannerState();
}

class _PulseBannerState extends State<_PulseBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: ScaleTransition(
        scale: _scale,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          onTap: widget.onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock DreamDrift Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Access all content and features',
                      style: TextStyle(
                        color: SleepColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: SleepColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
