import '../../models/sleep_log.dart';

abstract class SleepRepository {
  Future<List<SleepLog>> getLogs(String userId);
  Future<void> saveLog(SleepLog log);
  Future<void> deleteLog(String id);
}
