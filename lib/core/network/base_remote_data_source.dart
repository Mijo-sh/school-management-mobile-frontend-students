// core/network/base_remote_data_source.dart
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// كلاس أب لكل الـ remote data sources.
/// - يفكّ الـ ServerException يلي حطّها الـ DioErrorInterceptor جوّا الـ DioException.
/// - يمسك أي خطأ غير متوقع (مثلاً خطأ parsing) ويحوّله UnexpectedException.
/// كل data source بس بيلفّ محتوى الـ methods بـ execute(() async { ... }).
abstract class BaseRemoteDataSource {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      // الـ interceptor حطّ ServerException جوّا الـ error
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw const ServerException();
    } on ServerException {
      rethrow;
    } catch (_) {
      // أي خطأ ثاني (غالباً parsing / null) بيتحوّل UnexpectedException
      throw const UnexpectedException(message: 'حدث خطأ غير متوقع');
    }
  }
}