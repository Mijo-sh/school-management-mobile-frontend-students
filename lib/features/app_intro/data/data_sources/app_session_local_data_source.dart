import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/cache/cache_keys.dart';
import '../models/app_session_model.dart';
import 'package:dartz/dartz.dart';

abstract class AppSessionLocalDataSource {
  Future<AppSessionModel?> getCachedSession();
  Future<Unit> cacheSession(AppSessionModel sessionModel);
  Future<Unit> clearSession();
  Future<Unit> completeOnboarding();
  Future<Unit> clearAuthData();
}

class AppSessionLocalDataSourceImpl implements AppSessionLocalDataSource {
  final FlutterSecureStorage storage;

  AppSessionLocalDataSourceImpl({required this.storage});

  @override
  Future<AppSessionModel?> getCachedSession() async {
    final sessionJson = await storage.read(key: CacheKeys.appSession);
    if(sessionJson != null) {
      final sessionModel = AppSessionModel.fromJsonString(sessionJson);
      return sessionModel;
    }
    return null;
  }

  @override
  Future<Unit> cacheSession(AppSessionModel sessionModel) async {
    final jsonString = sessionModel.toJsonString();
    await storage.write(key: CacheKeys.appSession, value: jsonString);
    return unit;
  }

  @override
  Future<Unit> clearSession() async {
    await storage.delete(key: CacheKeys.appSession);
    return unit;
  }
  @override
  Future<Unit> completeOnboarding() async {
    final session = await getCachedSession();
    final updatedSession = AppSessionModel.fromEntity(
        session!.copyWith(isOnboardingCompleted: true)  
    );
    await cacheSession(updatedSession);
    return unit;
  }
  @override
  Future<Unit> clearAuthData() async {
    final session = await getCachedSession();

    // لو ما في جلسة، ما في شي نمسحه
    if (session == null) return unit;

    // نبني AppSessionModel جديد يدوياً: نُبقي onboarding، ونُفرّغ حقول auth
    // (ما نستخدم copyWith لأنها لا تقبل تعيين null)
    final cleared = AppSessionModel(
      isOnboardingCompleted: session.isOnboardingCompleted, // ← نحافظ عليها
      token: null,
      tokenExpiresAt: null,
      role: null,
    );

    await cacheSession(cleared);
    return unit;
  }
}