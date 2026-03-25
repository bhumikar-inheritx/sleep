import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/repositories/sleep_repository.dart';
import '../models/sleep_log.dart';

class SleepTrackerProvider extends ChangeNotifier {
  final SleepRepository _repository;
  final String? userId;
  List<SleepLog> _logs = [];
  bool _isDisposed = false;

  List<SleepLog> get logs => List.unmodifiable(_logs);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SleepTrackerProvider(this._repository, this.userId) {
    if (userId != null) {
      _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    if (userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _logs = await _repository.getLogs(userId!);
      _logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));
    } catch (e) {
      debugPrint('Error loading sleep logs: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> _saveLogs() async {
    // Repository handles individual saves
  }

  Future<void> addLog(SleepLog log) async {
    _logs.removeWhere((l) => l.id == log.id);
    _logs.add(log);
    _logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));
    notifyListeners();
    await _repository.saveLog(log);
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
    await _saveLogs();
  }

  Future<void> clearAll() async {
    _logs.clear();
    notifyListeners();
    await _saveLogs();
  }

  // Analytics Helpers

  double get averageSleepQuality {
    if (_logs.isEmpty) return 0.0;
    int total = _logs.fold(0, (sum, log) => sum + log.qualityRating);
    return total / _logs.length;
  }

  Duration get averageSleepDuration {
    if (_logs.isEmpty) return Duration.zero;
    int totalMinutes = _logs.fold(
      0,
      (sum, log) => sum + log.sleepDuration.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ _logs.length);
  }

  // Add dummy data for development visualization based on Phase 5 requirements
  void addDummyDataIfEmpty() {
    if (_logs.isNotEmpty) return;

    final now = DateTime.now();
    final dummyLogs = <SleepLog>[
      SleepLog(
        id: 'mock_1',
        bedtime: now.subtract(const Duration(days: 1, hours: 8)),
        wakeTime: now.subtract(const Duration(days: 1)),
        qualityRating: 4,
        mood: 'Refreshed',
        contentUsed: 'Rainy Forest',
      ),
      SleepLog(
        id: 'mock_2',
        bedtime: now.subtract(const Duration(days: 2, hours: 7, minutes: 30)),
        wakeTime: now.subtract(const Duration(days: 2)),
        qualityRating: 3,
        mood: 'Okay',
      ),
      SleepLog(
        id: 'mock_3',
        bedtime: now.subtract(const Duration(days: 3, hours: 9, minutes: 15)),
        wakeTime: now.subtract(const Duration(days: 3)),
        qualityRating: 5,
        mood: 'Great',
        contentUsed: 'Midnight Train Journey',
      ),
      SleepLog(
        id: 'mock_4',
        bedtime: now.subtract(const Duration(days: 4, hours: 6)),
        wakeTime: now.subtract(const Duration(days: 4)),
        qualityRating: 2,
        mood: 'Groggy',
      ),
      SleepLog(
        id: 'mock_5',
        bedtime: now.subtract(
          const Duration(days: 5, hours: 8, minutes: 42),
        ), // Reference to UI "8h 42m"
        wakeTime: now.subtract(const Duration(days: 5)),
        qualityRating: 4,
        mood: 'Refreshed',
      ),
    ];

    _logs.addAll(dummyLogs);
    _logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));
    _saveLogs();
    notifyListeners();
  }
}
