// core/network/dio_error_interceptor.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../injector/injector_container.dart';
import '../routing/app_router.dart';
import '../routing/route_name.dart';
import '../routing/selected_child_holder.dart';
import 'http_status_codes.dart';
import '../../features/auth/data/data_sources/local_data_source/auth_local_data_source.dart';
import '../../features/app_intro/domain/repositories/app_session_repository.dart';

class DioErrorInterceptor extends Interceptor {
  // يمنع تشغيل logout أكثر من مرة لو رجعت عدة طلبات 401 بنفس الوقت
  bool _isLoggingOut = false;

  // المسارات التي لا نُطبّق عليها auto-logout (المستخدم أصلاً خارج)
  static const _authPaths = [
    '/api/user/login',
    '/api/user/verify-otp',
    '/api/user/resend-otp',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🚨 [DIO] ${err.requestOptions.method} ${err.requestOptions.path}');
      debugPrint('🚨 Status: ${err.response?.statusCode} | Data: ${err.response?.data}');
    }

    final code = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthPath = _authPaths.any((p) => path.contains(p));

    // 401 على طلب غير طلبات الدخول → جلسة منتهية → logout تلقائي
    if (code == HttpStatusCodes.unauthorized && !isAuthPath) {
      _handleUnauthorized();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ServerException(message: _mapDioError(err)),
        type: err.type,
        response: err.response,
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    // حماية من الـ race condition: عدة طلبات ترجع 401 معاً
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // 1. مسح محلي فقط — بدون استدعاء remoteDataSource.logout()
      //    (لأنها تعمل طلب HTTP جديد قد يرجع 401 → حلقة)
      await di<AppSessionRepository>().clearAuthData();      await di<AuthLocalDataSource>().clear();
      di<SelectedChildHolder>().clear();
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [DIO] خطأ أثناء المسح المحلي: $e');
    } finally {
      // 2. التوجيه لصفحة الدخول عبر الـ router (بدون context)
      AppRouter.appRouter.go(RouteName.logIn);
      _isLoggingOut = false;
    }
  }

  String _mapDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String &&
        data.isNotEmpty &&
        !data.contains('<html') &&
        !data.contains('<!DOCTYPE')) {
      return data;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، حاول مرة أخرى';
      case DioExceptionType.connectionError:
        return 'تحقق من اتصالك بالإنترنت';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        switch (code) {
          case HttpStatusCodes.unauthorized:
            return 'انتهت صلاحية الجلسة، سجّل دخول من جديد';
          case HttpStatusCodes.forbidden:
            return 'ليس لديك صلاحية للوصول';
          case HttpStatusCodes.notFound:
            return 'المحتوى المطلوب غير موجود';
          case HttpStatusCodes.unprocessableEntity:
            return 'البيانات المُدخلة غير صحيحة';
          default:
            if (code != null && code >= HttpStatusCodes.internalServerError) {
              return 'خطأ في الخادم، حاول لاحقاً';
            }
            return 'حدث خطأ في الخادم';
        }
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}