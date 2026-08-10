// core/network/dio_error_interceptor.dart
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Interceptor مسؤوليته الوحيدة: يمسك أخطاء الـ Dio ويحوّلها
/// إلى ServerException مع رسالة عربية مفهومة للمستخدم.
/// يُسجَّل مرّة واحدة على مستوى التطبيق كله.
class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
        if (code == 422) {
          return e.response?.data?['message'] ?? 'البيانات المُدخلة غير صحيحة';
        }
        if (code != null && code >= 500) return 'خطأ في الخادم، حاول لاحقاً';
        return e.response?.data?['message'] ?? 'حدث خطأ في الخادم';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}