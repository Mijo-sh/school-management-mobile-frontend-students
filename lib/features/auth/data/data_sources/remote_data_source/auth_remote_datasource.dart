// lib/features/auth/data/data_sources/remote_data_source/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
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

class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> sendOtp(String phoneNumber) async {
    return execute(() async {
      final response = await dio.post(
        '/api/user/login',
        queryParameters: {'phone_number': phoneNumber},
      );
      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل الطلب',
        );
      }
      return (body is Map ? body['message']?.toString() : null) ?? 'تم بنجاح';
    });
  }

  @override
  Future<String> resendOtp(String phoneNumber) async {
    return execute(() async {
      final response = await dio.post(
        '/api/user/resend-otp',
        queryParameters: {'phone_number': phoneNumber},
      );
      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل الطلب',
        );
      }
      return (body is Map ? body['message']?.toString() : null) ?? 'تم بنجاح';
    });
  }

  @override
  Future<(UserModel, String)> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    return execute(() async {
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
    });
  }

  @override
  Future<String> logout() async {
    try {
      final response = await dio.post(
        '/api/user/logout',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل تسجيل الخروج',
        );
      }

      return (body is Map ? body['message']?.toString() : null) ?? 'تم بنجاح';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'تم تسجيل الخروج';
      }
      // إذا حدث خطأ آخر، نسمح لـ BaseRemoteDataSource بمعالجته أو نرميه كـ ServerException
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(message: e.response?.data?['message'] ?? 'خطأ في الخادم');
    }
  }
}