import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/schedule_entry_model .dart';

abstract class ScheduleLocalDataSource {
  Future<void> cacheWeekly(int studentId, Map<String, List<ScheduleEntryModel>> schedule);
  Future<Map<String, List<ScheduleEntryModel>>> getCachedWeekly(int studentId);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final SharedPreferences sharedPreferences;
  const ScheduleLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int studentId) => 'CACHED_SCHEDULE_$studentId';

  @override
  Future<void> cacheWeekly(
      int studentId, Map<String, List<ScheduleEntryModel>> schedule) async {
    try {
      final jsonMap = schedule.map((day, entries) =>
          MapEntry(day, entries.map((e) => e.toJson()).toList()));
      await sharedPreferences.setString(_keyFor(studentId), jsonEncode(jsonMap));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, List<ScheduleEntryModel>>> getCachedWeekly(int studentId) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) throw EmptyCacheException();
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map((day, entriesJson) {
        final entries = (entriesJson as List)
            .map((e) => ScheduleEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(day, entries);
      });
    } catch (e) {
      throw CacheException();
    }
  }
}
