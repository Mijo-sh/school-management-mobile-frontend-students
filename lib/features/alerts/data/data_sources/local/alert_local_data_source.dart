import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/alert_item_model.dart';

abstract class AlertLocalDataSource {
  /// يخزّن آخر نسخة ناجحة من القائمة — مفتاح مختلف لكل studentId
  /// (كل ابن عندو نسخته المحفوظة لحاله، متل ما بيصير بالسيرفر).
  Future<void> cacheAlerts(List<AlertItemModel> alerts, {int? studentId});

  /// يرجع آخر نسخة محفوظة. بيرمي [CacheException] لو ما في شي محفوظ
  /// أصلًا (أول مرة يفتح فيها التطبيق بدون نت مثلًا).
  Future<List<AlertItemModel>> getCachedAlerts({int? studentId});
}

class AlertLocalDataSourceImpl implements AlertLocalDataSource {
  final SharedPreferences sharedPreferences;
  const AlertLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) =>
      'CACHED_ALERTS_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheAlerts(List<AlertItemModel> alerts, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(alerts.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AlertItemModel>> getCachedAlerts({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) {
      throw EmptyCacheException();
    }
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => AlertItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }
}
