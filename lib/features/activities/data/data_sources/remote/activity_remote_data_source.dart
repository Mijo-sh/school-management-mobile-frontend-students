import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/activity_item_model.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityItemModel>> getActivities({int? studentId});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final Dio dio;
  ActivityRemoteDataSourceImpl({required this.dio});

  // TODO: تأكد من الأسماء الفعلية عبر:
  // php artisan route:list --path=activities
  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/my-activities'
        : '/api/user/child-activities';
  }

  @override
  Future<List<ActivityItemModel>> getActivities({int? studentId}) async {
    try {
      final response = await dio.get(
        _path(studentId),
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      final list = (response.data['data'] as List<dynamic>? ?? []);
      return list
          .map((e) => ActivityItemModel.fromJson(e as Map<String, dynamic>))
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
        '/api/user/activity-unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      // TODO: تأكد اسم الحقل بالاستجابة الفعلية (شفنا قبل إنو
      // alerts استخدمت "alerts" مش "count" — ممكن هون كمان يختلف).
      return (response.data['data']?['count'] as num?)?.toInt() ?? 0;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAllAsRead({int? studentId}) async {
    try {
      await dio.post(
        '/api/user/activity-mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
