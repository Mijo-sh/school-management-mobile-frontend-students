import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/grade_item_model.dart';

abstract class GradeLocalDataSource {
  Future<void> cacheGrades(List<GradeItemModel> grades, {int? studentId});
  Future<List<GradeItemModel>> getCachedGrades({int? studentId});
}

class GradeLocalDataSourceImpl implements GradeLocalDataSource {
  final SharedPreferences sharedPreferences;
  const GradeLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) =>
      'CACHED_GRADES_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheGrades(List<GradeItemModel> grades, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(grades.map((g) => g.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<GradeItemModel>> getCachedGrades({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) {
      throw CacheException();
    }
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => GradeItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }
}