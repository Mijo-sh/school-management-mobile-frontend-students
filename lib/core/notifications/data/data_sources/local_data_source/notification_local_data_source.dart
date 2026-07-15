import 'package:shared_preferences/shared_preferences.dart';

import '../../../../cache/cache_keys.dart';

abstract class NotificationLocalDataSource {
  Future<void> saveFcmToken(String token);
  Future<String?> getFcmToken();
  Future<void> clearFcmToken();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {

  @override
  Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CacheKeys.fcmToken, token);
  }

  @override
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(CacheKeys.fcmToken);
  }

  @override
  Future<void> clearFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(CacheKeys.fcmToken);
  }
}