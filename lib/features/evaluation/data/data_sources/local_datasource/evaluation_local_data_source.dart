import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/evaluation_item_model.dart';

abstract class EvaluationLocalDataSource {
  Future<void> cacheEvaluations(List<EvaluationItemModel> evaluations, {int? studentId});
  Future<List<EvaluationItemModel>> getCachedEvaluations({int? studentId});
}

class EvaluationLocalDataSourceImpl implements EvaluationLocalDataSource {
  final SharedPreferences sharedPreferences;
  const EvaluationLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) => 'CACHED_EVALUATIONS_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheEvaluations(List<EvaluationItemModel> evaluations, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(evaluations.map((e) => e.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<EvaluationItemModel>> getCachedEvaluations({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) throw CacheException();
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((e) => EvaluationItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException();
    }
  }
}
