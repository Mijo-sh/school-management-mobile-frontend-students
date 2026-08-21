import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

abstract class BaseRemoteDataSource {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ServerException {
      // مرمية من الـ data source نفسه (مثلاً status == false) — نمرّرها كما هي
      rethrow;
    } on DioException catch (e) {
      // 1. لو الـ interceptor غلّف الخطأ كـ ServerException، هي الأولوية
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }

      // 2. fallback: نقرأ رسالة الخادم من body (بأمان — فقط لو Map)
      final data = e.response?.data;
      final serverMessage = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : null;

      // 3. الأولوية الصحيحة: رسالة الخادم أولاً، وأخيراً الافتراضية
      //    ما عدنا نستخدم e.error.toString() لأنها رسالة تقنية للمستخدم
      throw ServerException(message: serverMessage ?? 'حدث خطأ في الخادم');
    } catch (e) {
  // لا تقم بعرض e.toString() للمستخدم أبداً لأنها تقنية
  throw const UnexpectedException(message: 'حدث خطأ غير متوقع، يجدر المحاولة لاحقاً');
  }
  }
}