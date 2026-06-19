import '../../features/app_intro/data/data_sources/app_session_local_data_source.dart';
import 'package:dio/dio.dart';

class DioAuthInterceptor extends Interceptor {
  final AppSessionLocalDataSource localDataSource;

  DioAuthInterceptor({required this.localDataSource});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = await localDataSource.getCachedSession();
    if (session?.token != null) {
      options.headers['Authorization'] = 'Bearer ${session!.token}';

    }
    handler.next(options);
  }
}