import 'package:hive_flutter/hive_flutter.dart';

class HiveDatasource {
  static const String profileBox = 'user_profile_box';
  static const String journalBox = 'journal_entries_box';
  static const String sleepBox = 'sleep_logs_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(profileBox);
    await Hive.openBox(journalBox);
    await Hive.openBox(sleepBox);
  }

  Future<void> put(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  dynamic get(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  Future<List<dynamic>> getAll(String boxName) async {
    final box = Hive.box(boxName);
    return box.values.toList();
  }

  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  Future<void> clear(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}
