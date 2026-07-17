import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/cache/cache_keys.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../shared/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });
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
      print("🧹 [AuthLocalDataSource]: بدأت عملية مسح التخزين...");

      // 1. مسح الـ Secure Storage
      await secureStorage.deleteAll();
      print("✅ [AuthLocalDataSource]: تم مسح SecureStorage.");

      // 2. مسح الـ SharedPreferences
      await sharedPreferences.clear();
      print("✅ [AuthLocalDataSource]: تم مسح SharedPreferences.");

    } catch (e, st) {
      // هذه الطباعة ستكشف لنا تماماً أين يقع الانهيار
      print("🚨 [AuthLocalDataSource]: فشل المسح بسبب: $e");
      print("StackTrace: $st");
      throw CacheException();
    }
  }
}