import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp({required String phoneNumber});
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> sendOtp({required String phoneNumber}) async {
    final response = await dio.post('/api/auth/send-otp', data: {
      'phone_number': phoneNumber,
    });
    return response.data['message'] ?? 'تم إرسال رمز التحقق بنجاح';
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final response = await dio.post('/api/auth/verify-otp', data: {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    });
    return response.data; // يعيد الـ Token والـ user_data
  }
}