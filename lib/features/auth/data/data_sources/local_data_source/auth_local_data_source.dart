import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../core/cache/cache_keys.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../profile/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(key: CacheKeys.token, value: token);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: CacheKeys.token);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await secureStorage.write(
        key: CacheKeys.user,
        value: jsonEncode(user.toJson()),
      );
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final raw = await secureStorage.read(key: CacheKeys.user);
      if (raw == null || raw.isEmpty) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> clear() async {
    try {
      await secureStorage.delete(key: CacheKeys.token);
      await secureStorage.delete(key: CacheKeys.user);
    } catch (_) {
      throw CacheException();
    }
  }
}