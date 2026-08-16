import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

abstract class BaseRemoteDataSource {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      // 1. إذا كان الـ error داخل الـ DioException هو ServerException أساساً
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }

      // 2. حل احتياطي: إذا كان الـ Interceptor قد وضع الرسالة داخل الـ response أو الـ error
      final errorMessage = e.error?.toString() ??
          e.response?.data?['message'] ??
          'حدث خطأ في الخادم';

      throw ServerException(message: errorMessage);

    } on ServerException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}