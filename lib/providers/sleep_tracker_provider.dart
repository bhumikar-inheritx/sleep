import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/sleep_log.dart';
import '../services/storage_service.dart';

class SleepTrackerProvider extends ChangeNotifier {
  static const String _storageKey = 'sleep_logs';
  List<SleepLog> _logs = [];

  List<SleepLog> get logs => List.unmodifiable(_logs);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SleepTrackerProvider() {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final logStrings = StorageService.getStringList(_storageKey);
      _logs = logStrings
          .map(
            (str) => SleepLog.fromJson(jsonDecode(str) as Map<String, dynamic>),
          )
          .toList();

      // Sort by bedtime descending (newest first)
      _logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));
    } catch (e) {
      debugPrint('Error loading sleep logs: $e');
      _logs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveLogs() async {
    try {
      final logStrings = _logs.map((log) => jsonEncode(log.toJson())).toList();
      await StorageService.setStringList(_storageKey, logStrings);
    } catch (e) {
      debugPrint('Error saving sleep logs: $e');
    }
  }

  Future<void> addLog(SleepLog log) async {
    // Add logic to avoid duplicate exact IDs
    _logs.removeWhere((l) => l.id == log.id);

    _logs.add(log);
    // Sort descending
    _logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));

    notifyListeners();
    await _saveLogs();
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
