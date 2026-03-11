/// App-wide constants for DreamDrift.
class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────
  static const String appName = 'DreamDrift';
  static const String appTagline = 'Fall asleep. Stay asleep. Wake refreshed.';

  // ─── Layout ───────────────────────────────────────
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXL = 32.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // ─── Animation Durations ──────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 1000);

  // ─── Audio Defaults ───────────────────────────────
  static const int defaultTimerMinutes = 30;
  static const int fadeOutDurationSeconds = 30;
  static const int maxMixerSounds = 5;

  // ─── Timer Options (in minutes) ───────────────────
  static const List<int> timerOptions = [15, 30, 45, 60, 90, 120];

  // ─── Sleep Score Thresholds ───────────────────────
  static const double sleepGoodThreshold = 7.0; // hours
  static const double sleepGreatThreshold = 8.0; // hours

  // ─── Content Categories ───────────────────────────
  static const List<String> storyCategories = [
    'All',
    'Nature',
    'Rain',
    'Train Rides',
    'Space',
    'Fairytales',
    'ASMR',
  ];

  static const List<String> soundCategories = [
    'All',
    'Rain',
    'White Noise',
    'Nature',
    'Forest',
  ];

  static const List<String> musicCategories = [
    'All',
    'Piano',
    'Lofi',
    'Binaural',
    'Ambient',
    'Classical',
  ];
}
