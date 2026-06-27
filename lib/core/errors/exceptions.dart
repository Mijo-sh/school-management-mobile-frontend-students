class CacheException implements Exception {}
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error.'});
}

class OfflineException implements Exception {}

class EmptyCacheException implements Exception {}
