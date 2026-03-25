import '../../domain/repositories/sleep_repository.dart';
import '../../models/sleep_log.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/firestore_datasource.dart';

class SleepRepositoryImpl implements SleepRepository {
  final FirestoreDatasource remoteDataSource;
  final HiveDatasource localDataSource;

  SleepRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<SleepLog>> getLogs(String userId) async {
    try {
      final remoteData = await remoteDataSource.getCollection('sleep_logs', userId: userId);
      final logs = remoteData.map((m) => SleepLog.fromJson(m)).toList();
      
      await localDataSource.clear(HiveDatasource.sleepBox);
      for (var log in remoteData) {
        await localDataSource.put(HiveDatasource.sleepBox, log['id'], log);
      }
      return logs;
    } catch (e) {
      final localData = await localDataSource.getAll(HiveDatasource.sleepBox);
      return localData.map((m) => SleepLog.fromJson(Map<String, dynamic>.from(m))).toList();
    }
  }

  @override
  Future<void> saveLog(SleepLog log) async {
    final data = log.toJson();
    await localDataSource.put(HiveDatasource.sleepBox, log.id, data);
    await remoteDataSource.setData('sleep_logs', log.id, data);
  }

  @override
  Future<void> deleteLog(String id) async {
    await localDataSource.delete(HiveDatasource.sleepBox, id);
    await remoteDataSource.deleteData('sleep_logs', id);
  }
}
