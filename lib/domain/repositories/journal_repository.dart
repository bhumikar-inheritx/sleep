import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getEntries(String userId);
  Future<void> saveEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
}
