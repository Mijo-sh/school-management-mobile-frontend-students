import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../domain/enums/theme_type.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

abstract class ThemeLocalDataSource {
  Future<ThemeType> getCachedTheme();
  Future<Unit> cacheTheme(ThemeType theme);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences preferences;

  ThemeLocalDataSourceImpl({required this.preferences});

  @override
  Future<ThemeType> getCachedTheme() async {
    var theme = preferences.getString(CacheKeys.appTheme);
    if(theme != null) {
      return theme == 'light' ? ThemeType.light : ThemeType.dark;
    }
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.light ? ThemeType.light : ThemeType.dark;
  }

  @override
  Future<Unit> cacheTheme(ThemeType theme) async {
    await preferences.setString(CacheKeys.appTheme, theme.name);
    return unit;
  }
}