import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../profile/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> cacheUser(UserModel userModel);
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'AUTH_TOKEN', value: token);
  }

  @override
  Future<void> cacheUser(UserModel userModel) async {
    final jsonString = jsonEncode(userModel.toJson());
    await secureStorage.write(key: 'CACHED_USER', value: jsonString);
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: 'AUTH_TOKEN');
    await secureStorage.delete(key: 'CACHED_USER');
  }
}