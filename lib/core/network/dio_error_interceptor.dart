// core/network/dio_error_interceptor.dart
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🚨 [DIO ERROR]: URL -> ${err.requestOptions.path}');
    print('🚨 [DIO ERROR]: Status Code -> ${err.response?.statusCode}');
    print('🚨 [DIO ERROR]: Response Data Type -> ${err.response?.data.runtimeType}');
    print('🚨 [DIO ERROR]: Response Data -> ${err.response?.data}');

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ServerException(message: _mapDioError(err)),
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _mapDioError(DioException e) {
    final data = e.response?.data;

    // 1. إذا كان الـ data عبارة عن Map ويحتوي على message
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    // 2. إذا كان الـ data عبارة عن String (أحيانًا السيرفر يرجع النص مباشرة)
    if (data is String && data.isNotEmpty) {
      // نتأكد ألا يكون صفحة HTML للخطأ
      if (!data.contains('<html') && !data.contains('<!DOCTYPE')) {
        return data;
      }
    }

    // 3. التعامل مع باقي الأنواع حسب الكود
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، حاول مرة أخرى';
      case DioExceptionType.connectionError:
        return 'تحقق من اتصالك بالإنترنت';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return 'انتهت صلاحية الجلسة، سجّل دخول من جديد';
        if (code == 403) return 'ليس لديك صلاحية للوصول';
        if (code == 404) return 'المحتوى المطلوب غير موجود';
        if (code == 422) return 'البيانات المُدخلة غير صحيحة';
        if (code != null && code >= 500) return 'خطأ في الخادم، حاول لاحقاً';
        return 'حدث خطأ في الخادم';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}