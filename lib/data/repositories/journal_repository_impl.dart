import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/firestore_datasource.dart';

class JournalRepositoryImpl implements JournalRepository {
  final FirestoreDatasource remoteDataSource;
  final HiveDatasource localDataSource;

  JournalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<JournalEntry>> getEntries(String userId) async {
    try {
      final remoteData = await remoteDataSource.getCollection('journals', userId: userId);
      final entries = remoteData.map((m) => JournalEntry.fromMap(m)).toList();
      
      // Update local cache
      await localDataSource.clear(HiveDatasource.journalBox);
      for (var entry in remoteData) {
        await localDataSource.put(HiveDatasource.journalBox, entry['id'], entry);
      }
      return entries;
    } catch (e) {
      final localData = await localDataSource.getAll(HiveDatasource.journalBox);
      return localData.map((m) => JournalEntry.fromMap(Map<String, dynamic>.from(m))).toList();
    }
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    final data = entry.toMap();
    await localDataSource.put(HiveDatasource.journalBox, entry.id, data);
    await remoteDataSource.setData('journals', entry.id, data);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await localDataSource.delete(HiveDatasource.journalBox, id);
    await remoteDataSource.deleteData('journals', id);
  }
}
