import 'package:dartz/dartz.dart';
import '../enums/theme_type.dart';

abstract class ThemeRepository {
  Future<ThemeType> getTheme();
  Future<Unit> saveTheme(ThemeType theme);
}