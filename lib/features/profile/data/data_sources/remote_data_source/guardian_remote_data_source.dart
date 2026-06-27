import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/child_of_parent.dart';

abstract class GuardianRemoteDataSource {
  Future<List<ChildCardModel>> getChildren();
}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  final Dio dio;
  GuardianRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChildCardModel>> getChildren() async {
    try {
      final response = await dio.get('/api/user/get-user-data');
      final body = response.data;

      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب البيانات',
        );
      }

      final data = body['data'] as Map<String, dynamic>;
      final list = (data['children_cards'] as List<dynamic>? ?? [])
          .map((e) => ChildCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    } catch (_) {
      throw const ServerException();
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'تعذّر الاتصال بالخادم، تحقّق من الإنترنت';
    }
    return 'خطأ في الخادم، حاول مجدداً';
  }
}