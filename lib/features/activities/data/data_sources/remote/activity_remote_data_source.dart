// lib/features/activity/data/data_sources/remote/activity_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/activity_item_model.dart';

abstract class ActivityRemoteDataSource {
  Future<PaginatedModel<ActivityItemModel>> getActivities({int? studentId, int page = 1});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class ActivityRemoteDataSourceImpl extends BaseRemoteDataSource implements ActivityRemoteDataSource {
  final Dio dio;
  ActivityRemoteDataSourceImpl({required this.dio});

  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/my-activities'
        : '/api/user/child-activities';
  }

  @override
  Future<PaginatedModel<ActivityItemModel>> getActivities({int? studentId, int page = 1}) async {
    return execute(() async {
      debugPrint("🚀 [ActivityRemote] جاري جلب الأنشطة للصفحة: $page | studentId: $studentId");

      final Map<String, dynamic> params = {'page': page};
      if (studentId != null) {
        params['student_id'] = studentId;
      }

      final response = await dio.get(
        _path(studentId),
        queryParameters: params,
      );

      debugPrint("✅ [ActivityRemote] تم جلب الأنشطة بنجاح. الرد: ${response.data}");

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب الأنشطة',
        );
      }

      return PaginatedModel<ActivityItemModel>.fromJson(
        body as Map<String, dynamic>,
            (itemJson) => ActivityItemModel.fromJson(itemJson as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    return execute(() async {
      debugPrint("🚀 [ActivityRemote] جاري جلب عدد غير المقروءة | studentId: $studentId");

      final response = await dio.get(
        '/api/user/activity-unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      debugPrint("✅ [ActivityRemote] رد unread-count: ${response.data}");

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب عدد غير المقروءة',
        );
      }

      return (body['data']?['count'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAllAsRead({int? studentId}) async {
    return execute(() async {
      debugPrint("🚀 [ActivityRemote] جاري تنفيذ markAllAsRead | studentId: $studentId");

      final response = await dio.post(
        '/api/user/activity-mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      debugPrint("✅ [ActivityRemote] تم تنفيذ markAllAsRead بنجاح. الرد: ${response.data}");

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل تحديث حالة القراءة',
        );
      }
    });
  }
}