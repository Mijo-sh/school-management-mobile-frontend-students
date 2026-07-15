import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/alert_item_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertItemModel>> getAlerts({int? studentId});

  /// endpoint حقيقي وواحد للدورين (student_id اختياري يميّز بينهم).
  Future<int> getUnreadCount({int? studentId});

  /// تصفير الكل دفعة وحدة — نفس نمط الإعلانات بالضبط، مش تعليم
  /// عنصر واحد لحاله.
  Future<void> markAsRead({int? studentId});
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final Dio dio;
  AlertRemoteDataSourceImpl({required this.dio});

  // المسارات منفصلة بالكامل حسب الدور — my-alerts للطالب (بدون أي
  // parameter)، child-alerts لولي الأمر (مع student_id اختياري
  // كـ query parameter، مش جزء من الرابط).
  String _alertsPath(int? studentId) {
    return studentId == null
        ? '/api/user/my-alerts'
        : '/api/user/child-alerts/$studentId';
  }

  @override
  Future<List<AlertItemModel>> getAlerts({int? studentId}) async {
    try {
      final response = await dio.get(_alertsPath(studentId));
      final list = (response.data['data'] as List<dynamic>? ?? []);
      return list
          .map((e) => AlertItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    try {
      final response = await dio.get(
        '/api/user/alerts/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      // الشكل الفعلي: {"data": {"alerts": N, "payment_alerts": N}}
      return (response.data['data']?['alerts'] as num?)?.toInt() ?? 0;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead({int? studentId}) async {
    try {
      await dio.post(
        '/api/user/alerts/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId,'category':"general"} : {'category':"general"},

      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}