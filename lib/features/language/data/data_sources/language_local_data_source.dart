import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../domain/enums/language_type.dart';
import 'package:dartz/dartz.dart';
import 'dart:ui';

abstract class LanguageLocalDataSource {
  Future<LanguageType> getCachedLanguage();
  Future<Unit> cacheLanguage(LanguageType language);
}

class LanguageLocalDataSourceImpl implements LanguageLocalDataSource {
  final SharedPreferences preferences;

  LanguageLocalDataSourceImpl({required this.preferences});

  @override
  Future<LanguageType> getCachedLanguage() async {
    var language = preferences.getString(CacheKeys.appLanguage);
    if(language != null) {
      return language == 'ar' ? LanguageType.ar : LanguageType.en;
    }
    final systemLanguage = PlatformDispatcher.instance.locale.languageCode;
    if (systemLanguage == 'ar') {
      return LanguageType.ar;
    }
    return LanguageType.en;
  }

  @override
  Future<Unit> cacheLanguage(LanguageType language) async {
    await preferences.setString(CacheKeys.appLanguage, language.name);
    return unit;
  }
}