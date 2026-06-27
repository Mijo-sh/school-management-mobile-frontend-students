import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../cache/cache_keys.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    options.headers['Accept'] = 'application/json';
    final token = await secureStorage.read(key: CacheKeys.token);

    // 👇 طباعة للتأكد
    print('🌐 REQUEST TO: ${options.path}');
    print('🔑 INTERCEPTOR TOKEN: $token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('✅ HEADER ADDED: Bearer ${token.substring(0, 5)}...');
    } else {
      print('❌ NO TOKEN — header NOT added');
    }
    handler.next(options);
  }
}