import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/evaluation_item_model.dart';

abstract class EvaluationRemoteDataSource {
  Future<PaginatedModel<EvaluationItemModel>> getEvaluations({int? studentId, int page = 1});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class EvaluationRemoteDataSourceImpl implements EvaluationRemoteDataSource {
  final Dio dio;
  EvaluationRemoteDataSourceImpl({required this.dio});

  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/show/own/evaluations'
        : '/api/user/show/child/evaluations/${studentId}';
  }

  @override
  Future<PaginatedModel<EvaluationItemModel>> getEvaluations({int? studentId, int page = 1}) async {
    try {
      final response = await dio.get(
        _path(studentId),
        queryParameters: {
          'page': page,
        },
      );
      return PaginatedModel<EvaluationItemModel>.fromJson(
        response.data as Map<String, dynamic>,
        (item) => EvaluationItemModel.fromJson(item as Map<String, dynamic>),
      );
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
        '/api/user/evaluation/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      return (response.data['data']?['unread_count'] as num?)?.toInt() ?? 0;
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
        '/api/user/evaluation/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
