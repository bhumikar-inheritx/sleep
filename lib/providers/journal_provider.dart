import 'package:flutter/foundation.dart';
import '../domain/entities/journal_entry.dart';
import '../domain/repositories/journal_repository.dart';
import 'package:uuid/uuid.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository;
  final String? userId;

  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  bool _isDisposed = false;

  JournalProvider(this._repository, this.userId) {
    if (userId != null) {
      loadEntries();
    }
  }

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    if (userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.getEntries(userId!);
      _entries.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
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

  Future<void> addEntry({
    required int moodIndex,
    required double sleepQuality,
    required String notes,
  }) async {
    if (userId == null) return;

    final entry = JournalEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      moodIndex: moodIndex,
      sleepQuality: sleepQuality,
      notes: notes,
      userId: userId,
    );

    _entries.insert(0, entry);
    notifyListeners();

    await _repository.saveEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _repository.deleteEntry(id);
  }
}
