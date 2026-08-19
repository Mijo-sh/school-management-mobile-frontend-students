import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/payment_alert_item_model.dart';

abstract class PaymentAlertLocalDataSource {
  Future<void> cacheAlerts(List<PaymentAlertItemModel> alerts, {int? studentId});
  Future<List<PaymentAlertItemModel>> getCachedAlerts({int? studentId});
}

class PaymentAlertLocalDataSourceImpl implements PaymentAlertLocalDataSource {
  final SharedPreferences sharedPreferences;
  const PaymentAlertLocalDataSourceImpl({required this.sharedPreferences});

  // مفتاح مختلف عن التنبيهات العادية حتى ما يتضاربوا
  String _keyFor(int? studentId) =>
      'CACHED_PAYMENT_ALERTS_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheAlerts(
      List<PaymentAlertItemModel> alerts, {
        int? studentId,
      }) async {
    try {
      final jsonString = jsonEncode(alerts.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<PaymentAlertItemModel>> getCachedAlerts({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) {
      throw EmptyCacheException();
    }
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) =>
          PaymentAlertItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }
}