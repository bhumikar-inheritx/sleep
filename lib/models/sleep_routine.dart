/// Defines the structure of a wind-down routine (e.g., Breathing -> Body Scan)
class SleepRoutine {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final List<RoutineStep> steps;

  const SleepRoutine({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.steps,
  });
}

enum RoutineStepType {
  breathing,
  bodyScan,
  stretch,
  journal,
}

class RoutineStep {
  final String title;
  final String description;
  final int durationSeconds;
  final RoutineStepType type;
  final Map<String, dynamic> config; // e.g., {'inhale': 4, 'hold': 7, 'exhale': 8}

  const RoutineStep({
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.type,
    this.config = const {},
  });
}
