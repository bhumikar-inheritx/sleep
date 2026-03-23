import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  static final Health _health = Health();

  static const List<HealthDataType> types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
  ];

  static Future<bool> requestPermissions() async {
    // On Android, we need to request Activity Recognition permission for some health data
    if (await Permission.activityRecognition.request().isGranted) {
      return await _health.requestAuthorization(types);
    }
    return false;
  }

  static Future<List<HealthDataPoint>> fetchSleepData(DateTime start, DateTime end) async {
    try {
      return await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );
    } catch (e) {
      print('Error fetching sleep data: $e');
      return [];
    }
  }

  static Future<bool> writeSleepData({
    required DateTime bedtime,
    required DateTime wakeTime,
  }) async {
    try {
      return await _health.writeHealthData(
        startTime: bedtime,
        endTime: wakeTime,
        type: HealthDataType.SLEEP_ASLEEP,
        value: wakeTime.difference(bedtime).inMinutes.toDouble(),
      );
    } catch (e) {
      print('Error writing sleep data: $e');
      return false;
    }
  }
}
