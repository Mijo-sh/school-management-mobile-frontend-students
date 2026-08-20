// core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error.'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error.'});
}

class OfflineException implements Exception {
  final String message;
  const OfflineException({this.message = 'No internet connection.'});
}

class EmptyCacheException implements Exception {
  final String message;
  const EmptyCacheException({this.message = 'No cached data.'});
}

class UnexpectedException implements Exception {
  final String message;
  const UnexpectedException({this.message = 'Unexpected error.'});
}