import 'package:flutter/material.dart';

enum RoutineStepType { journal, meditation, music, soundscape, breathing }

class RoutineStep {
  final String id;
  final RoutineStepType type;
  final String title;
  final Duration duration;
  final String? contentId; // ID of story/music/meditation if applicable

  const RoutineStep({
    required this.id,
    required this.type,
    required this.title,
    required this.duration,
    this.contentId,
  });

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
      id: json['id'] as String,
      type: RoutineStepType.values.firstWhere(
        (e) => e.toString() == 'RoutineStepType.${json['type']}',
        orElse: () => RoutineStepType.breathing,
      ),
      title: json['title'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 300),
      contentId: json['contentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'durationSeconds': duration.inSeconds,
      'contentId': contentId,
    };
  }
}

class SleepRoutine {
  final String id;
  final String name;
  final List<RoutineStep> steps;
  final bool isEnabled;

  const SleepRoutine({
    required this.id,
    required this.name,
    required this.steps,
    this.isEnabled = true,
  });

  factory SleepRoutine.fromJson(Map<String, dynamic> json) {
    return SleepRoutine(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'My Wind-Down',
      steps: (json['steps'] as List? ?? [])
          .map((s) => RoutineStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'steps': steps.map((s) => s.toJson()).toList(),
      'isEnabled': isEnabled,
    };
  }
  
  SleepRoutine copyWith({
    String? name,
    List<RoutineStep>? steps,
    bool? isEnabled,
  }) {
    return SleepRoutine(
      id: id,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
