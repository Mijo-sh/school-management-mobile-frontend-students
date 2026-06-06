import 'package:shared_preferences/shared_preferences.dart';
import '../../factories/app_session_default_factory.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/cache/cache_keys.dart';
import '../models/app_session_model.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';

abstract class AppSessionLocalDataSource {
  Future<AppSessionModel> getCachedSession();
  Future<Unit> cacheSession(AppSessionModel sessionModel);
  Future<Unit> clearSession();
  Future<Unit> completeOnboarding();
}

class AppSessionLocalDataSourceImpl implements AppSessionLocalDataSource {
  final SharedPreferences preferences;

  AppSessionLocalDataSourceImpl({required this.preferences});

  @override
  Future<AppSessionModel> getCachedSession() async {
    final isCompleted = preferences.getBool(CacheKeys.onboarding) ?? false;
    final session = preferences.getString(CacheKeys.appSession);
    if(session != null) {
      final decoded = jsonDecode(session);
      return AppSessionModel.fromJson(decoded);
    }
    final defaultSession = AppSessionModel.fromEntity(
      AppSessionDefaultFactory.create().copyWith(isOnboardingCompleted: isCompleted
      ));
    final encoded = jsonEncode(defaultSession.toJson());
    await preferences.setString(CacheKeys.appSession, encoded);
    return defaultSession;
  }

  @override
  Future<Unit> cacheSession(AppSessionModel sessionModel) async {
    final jsonSession = jsonEncode(sessionModel.toJson());
    final cachedSession = await preferences.setString(CacheKeys.appSession, jsonSession);
    if(!cachedSession) throw CacheException();
    return unit;
  }

  @override
  Future<Unit> clearSession() async {
    final clearSession = await preferences.remove(CacheKeys.appSession);
    if(!clearSession) throw CacheException();
    return unit;
  }

  @override
  Future<Unit> completeOnboarding() async {
    final success = await preferences.setBool(CacheKeys.onboarding, true);
    if(!success) throw CacheException();
    return unit;
  }
}