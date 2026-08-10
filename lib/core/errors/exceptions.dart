// core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error.'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error.'});
}

class OfflineException implements Exception {}

class EmptyCacheException implements Exception {}

class UnexpectedException implements Exception {
  final String message;
  const UnexpectedException({this.message = 'Unexpected error.'});
}