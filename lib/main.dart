import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/audio_player_provider.dart';
import 'providers/content_provider.dart';
import 'providers/sound_mixer_provider.dart';
import 'providers/sleep_tracker_provider.dart';
import 'providers/alarm_provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/explore/stories_screen.dart';
import 'screens/explore/soundscapes_screen.dart';
import 'screens/explore/music_screen.dart';
import 'screens/routines/breathing_exercise_screen.dart';
import 'screens/alarm/alarm_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system overlay style (status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DreamDriftApp());
}

class DreamDriftApp extends StatelessWidget {
  const DreamDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => SoundMixerProvider()),
        ChangeNotifierProvider(create: (_) => SleepTrackerProvider()..addDummyDataIfEmpty()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        title: 'DreamDrift',
        debugShowCheckedModeBanner: false,
        theme: SleepTheme.darkTheme,
        initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.explore: (context) => const ExploreScreen(),
        AppRoutes.stories: (context) => const StoriesScreen(),
        AppRoutes.soundscapes: (context) => const SoundscapesScreen(),
        AppRoutes.music: (context) => const MusicScreen(),
        AppRoutes.breathingExercise: (context) => const BreathingExerciseScreen(),
        AppRoutes.alarm: (context) => const AlarmScreen(),
      },
      ),
    );
  }
}
