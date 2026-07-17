import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/activity_item_model.dart';

abstract class ActivityRemoteDataSource {
  Future<PaginatedModel<ActivityItemModel>> getActivities({int? studentId, int page = 1});
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
  Future<PaginatedModel<ActivityItemModel>> getActivities({int? studentId, int page = 1}) async {
    try {
      // 1. تجهيز المعاملات بشكل صحيح لضمان وصولها للسيرفر
      final Map<String, dynamic> params = {'page': page};
      if (studentId != null) {
        params['student_id'] = studentId;
      }

      final response = await dio.get(
        _path(studentId),
        queryParameters: params, // إرسال المعاملات هنا ضروري جداً
      );

      // 2. التحويل باستخدام PaginatedModel الذي يعتمد على مفتاح "data"
      return PaginatedModel<ActivityItemModel>.fromJson(
        response.data as Map<String, dynamic>,
            (itemJson) => ActivityItemModel.fromJson(itemJson as Map<String, dynamic>),
      );

    } on DioException catch (e) {
      // معالجة أفضل للأخطاء القادمة من السيرفر
      throw ServerException(
          message: e.response?.data?['message'] ?? 'خطأ في الاتصال بالأنشطة');
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
