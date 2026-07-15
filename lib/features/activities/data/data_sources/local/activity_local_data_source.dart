import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/activity_item_model.dart';

abstract class ActivityLocalDataSource {
  Future<void> cacheActivities(List<ActivityItemModel> activities, {int? studentId});

  Future<List<ActivityItemModel>> getCachedActivities({int? studentId});
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final SharedPreferences sharedPreferences;
  const ActivityLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) =>
      'CACHED_ACTIVITIES_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheActivities(List<ActivityItemModel> activities, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(activities.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ActivityItemModel>> getCachedActivities({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) {
      throw CacheException();
    }
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => ActivityItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }
}
