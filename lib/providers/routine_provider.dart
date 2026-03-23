import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/routine.dart';

class RoutineProvider extends ChangeNotifier {
  SleepRoutine? _currentRoutine;
  int _currentStepIndex = -1;
  bool _isActive = false;
  bool _isCompleted = false;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  SleepRoutine? get currentRoutine => _currentRoutine;
  int get currentStepIndex => _currentStepIndex;
  bool get isActive => _isActive;
  bool get isCompleted => _isCompleted;
  Duration get remainingTime => _remainingTime;
  
  RoutineStep? get currentStep {
    if (_currentRoutine == null || _currentStepIndex < 0 || _currentStepIndex >= _currentRoutine!.steps.length) {
      return null;
    }
    return _currentRoutine!.steps[_currentStepIndex];
  }

  void startRoutine(SleepRoutine routine) {
    _currentRoutine = routine;
    _currentStepIndex = 0;
    _isActive = true;
    _isCompleted = false;
    _startStep();
    notifyListeners();
  }

  void _startStep() {
    final step = currentStep;
    if (step == null) {
      stopRoutine();
      return;
    }
    _remainingTime = step.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        nextStep();
      }
    });
  }

  void nextStep() {
    if (_currentRoutine == null) return;
    
    if (_currentStepIndex < _currentRoutine!.steps.length - 1) {
      _currentStepIndex++;
      _startStep();
      notifyListeners();
    } else {
      _finishRoutine();
    }
  }

  void _finishRoutine() {
    _timer?.cancel();
    _isActive = true; // Keep active to show completion screen
    _isCompleted = true;
    _currentStepIndex = -1;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _startStep();
      notifyListeners();
    }
  }

  void stopRoutine() {
    _timer?.cancel();
    _isActive = false;
    _isCompleted = false;
    _currentStepIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
