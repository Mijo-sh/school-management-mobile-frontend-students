import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/grade_item_model.dart';

abstract class GradeRemoteDataSource {
  Future<PaginatedModel<GradeItemModel>> getGrades({int? studentId, int page = 1});
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAllAsRead({int? studentId});
}

class GradeRemoteDataSourceImpl implements GradeRemoteDataSource {
  final Dio dio;
  GradeRemoteDataSourceImpl({required this.dio});



  @override
  Future<PaginatedModel<GradeItemModel>> getGrades({int? studentId, int page = 1}) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (studentId != null) {
        params['student_id'] = studentId;
      }

      final response = await dio.get(
      "/api/user/marks/show/all",
        queryParameters: params,
      );

      return PaginatedModel<GradeItemModel>.fromJson(
        response.data as Map<String, dynamic>,
            (itemJson) => GradeItemModel.fromJson(itemJson as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? 'خطأ في الاتصال بالعلامات');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    try {
      final response = await dio.get(
        '/api/user/marks/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      return (response.data['data']?['unread_marks_count'] as num?)?.toInt() ?? 0;
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
        '/api/user/marks/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}