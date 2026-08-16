// lib/features/homework/data/data_sources/remote_datasource/homework_remote_data_source.dart

import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/homework_item_model.dart';

abstract class HomeworkRemoteDataSource {
  Future<PaginatedModel<HomeworkItemModel>> getHomeworks({int? studentId, int page = 1});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class HomeworkRemoteDataSourceImpl extends BaseRemoteDataSource
    implements HomeworkRemoteDataSource {
  final Dio dio;
  HomeworkRemoteDataSourceImpl({required this.dio});

  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/show/own/homeworks'
        : '/api/user/show/child/homeworks/$studentId';
  }

  @override
  Future<PaginatedModel<HomeworkItemModel>> getHomeworks({int? studentId, int page = 1}) async {
    return execute(() async {
      final response = await dio.get(_path(studentId), queryParameters: {'page': page});

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب الوظائف',
        );
      }

      return PaginatedModel<HomeworkItemModel>.fromJson(
        body as Map<String, dynamic>,
            (item) => HomeworkItemModel.fromJson(item as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    return execute(() async {
      final response = await dio.get(
        '/api/user/homeworks/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب العدد غير المقروء',
        );
      }

      return (body['data']?['unread_count'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAllAsRead({int? studentId}) async {
    return execute(() async {
      final response = await dio.post(
        '/api/user/homeworks/mark-all-read',
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