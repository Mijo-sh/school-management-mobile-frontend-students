// lib/features/evaluation/data/data_sources/remote_datasource/evaluation_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/evaluation_item_model.dart';

abstract class EvaluationRemoteDataSource {
  Future<PaginatedModel<EvaluationItemModel>> getEvaluations({int? studentId, int page = 1});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class EvaluationRemoteDataSourceImpl extends BaseRemoteDataSource
    implements EvaluationRemoteDataSource {
  final Dio dio;
  EvaluationRemoteDataSourceImpl({required this.dio});

  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/show/own/evaluations'
        : '/api/user/show/child/evaluations/$studentId';
  }

  @override
  Future<PaginatedModel<EvaluationItemModel>> getEvaluations({int? studentId, int page = 1}) async {
    return execute(() async {
      final response = await dio.get(
        _path(studentId),
        queryParameters: {
          'page': page,
        },
      );

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب التقييمات',
        );
      }

      return PaginatedModel<EvaluationItemModel>.fromJson(
        body as Map<String, dynamic>,
            (item) => EvaluationItemModel.fromJson(item as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    return execute(() async {
      final response = await dio.get(
        '/api/user/evaluation/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب عدد غير Read',
        );
      }

      return (body['data']?['unread_count'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAllAsRead({int? studentId}) async {
    return execute(() async {
      final response = await dio.post(
        '/api/user/evaluation/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل تحديث الحالة',
        );
      }
    });
  }
}