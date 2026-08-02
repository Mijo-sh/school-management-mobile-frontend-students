import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/homework_item_model.dart';

abstract class HomeworkLocalDataSource {
  Future<void> cacheHomeworks(List<HomeworkItemModel> homeworks, {int? studentId});
  Future<List<HomeworkItemModel>> getCachedHomeworks({int? studentId});
}

class HomeworkLocalDataSourceImpl implements HomeworkLocalDataSource {
  final SharedPreferences sharedPreferences;
  const HomeworkLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) => 'CACHED_HOMEWORKS_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheHomeworks(List<HomeworkItemModel> homeworks, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(homeworks.map((h) => h.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<HomeworkItemModel>> getCachedHomeworks({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) throw CacheException();
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((e) => HomeworkItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException();
    }
  }
}
