import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/alarm_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/sleep_tracker_provider.dart';
import 'providers/sound_mixer_provider.dart';
import 'services/storage_service.dart';
import 'services/notifications_service.dart';
import 'screens/alarm/alarm_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/explore/music_screen.dart';
import 'screens/explore/soundscapes_screen.dart';
import 'screens/explore/stories_screen.dart';
import 'screens/explore/meditations_screen.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/routines/breathing_exercise_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Storage
  await StorageService.init();
  await NotificationsService.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => SoundMixerProvider()),
        ChangeNotifierProvider(
          create: (_) => SleepTrackerProvider()..addDummyDataIfEmpty(),
        ),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProxyProvider2<AuthProvider, ContentProvider, RecommendationProvider>(
          create: (context) => RecommendationProvider(
            auth: Provider.of<AuthProvider>(context, listen: false),
            content: Provider.of<ContentProvider>(context, listen: false),
          ),
          update: (context, auth, content, previous) =>
              RecommendationProvider(auth: auth, content: content),
        ),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'DreamDrift',
          debugShowCheckedModeBanner: false,
          theme: SleepTheme.darkTheme,
          locale: localeProvider.locale,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.signup: (context) => const SignupScreen(),
            AppRoutes.main: (context) => const MainScreen(),
            AppRoutes.explore: (context) => const ExploreScreen(),
            AppRoutes.stories: (context) => const StoriesScreen(),
            AppRoutes.meditations: (context) => const MeditationsScreen(),
            AppRoutes.soundscapes: (context) => const SoundscapesScreen(),
            AppRoutes.music: (context) => const MusicScreen(),
            AppRoutes.breathingExercise: (context) => const BreathingExerciseScreen(),
            AppRoutes.alarm: (context) => const AlarmScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          },
        ),
      ),
    );
  }
}
