import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../shared/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);
  Future<String> resendOtp(String phoneNumber);
  Future<(UserModel, String)> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
  Future<String> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> sendOtp(String phoneNumber) =>
      _postForMessage('/api/user/login', {'phone_number': phoneNumber});

  @override
  Future<String> resendOtp(String phoneNumber) =>
      _postForMessage('/api/user/resend-otp', {'phone_number': phoneNumber});

  @override
  Future<(UserModel, String)> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        '/api/user/verify-otp',
        queryParameters: {'phone_number': phoneNumber, 'otp': otp},
      );
      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل تسجيل الدخول',
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'].toString();
      return (user, token);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    } catch (_) {
      throw const ServerException();
    }
  }

  Future<String> _postForMessage(String path,
      Map<String, dynamic> queryParameters,) async {
    try {
      final response = await dio.post(path, queryParameters: queryParameters);
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw ServerException(
          message: data['message']?.toString() ?? 'فشل الطلب',
        );
      }
      return (data is Map ? data['message']?.toString() : null) ?? 'تم بنجاح';
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: _extractMessage(e));
    } catch (_) {
      throw const ServerException();
    }
  }

  /// يستخرج رسالة الخطأ القادمة من Laravel (message أو errors)
  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'تعذّر الاتصال بالخادم، تحقّق من الإنترنت';
    }
    return 'خطأ في الخادم، حاول مجدداً';
  }

  @override
  Future<String> logout() async {
    try {
      // الـ Interceptor سيقوم بإضافة الـ Authorization Header تلقائياً
      final response = await dio.post(
        '/api/user/logout',
        options: Options(
          headers: {
            'Accept': 'application/json', // أضفنا هذا للتأكد من توافق Laravel
          },
        ),
      );

      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw ServerException(
          message: data['message']?.toString() ?? 'فشل تسجيل الخروج',
        );
      }

      return (data is Map ? data['message']?.toString() : null) ?? 'تم بنجاح';
    } on DioException catch (e) {
      // إذا حصلنا على 401، فهذا يعني أن التوكين غير صالح بالفعل
      // نعتبر العملية ناجحة لكي نكمل مسح الكاش محلياً
      if (e.response?.statusCode == 401) {
        return 'تم تسجيل الخروج';
      }
      throw ServerException(message: _extractMessage(e));
    } catch (e) {
      throw const ServerException();
    }
  }
}