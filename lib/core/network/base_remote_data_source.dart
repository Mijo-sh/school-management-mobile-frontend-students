import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

abstract class BaseRemoteDataSource {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }

      // 👇 فحص آمن: نفهرس message فقط لو data فعلاً Map
      final data = e.response?.data;
      final serverMessage =
      (data is Map && data['message'] != null)
          ? data['message'].toString()
          : null;

      final errorMessage = e.error?.toString() ??
          serverMessage ??
          'حدث خطأ في الخادم';

      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}