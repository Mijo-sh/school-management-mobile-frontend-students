import '../repositories/theme_repository.dart';
import '../enums/theme_type.dart';
import 'package:dartz/dartz.dart';

class SaveThemeUseCase {
  final ThemeRepository repository;

  SaveThemeUseCase({required this.repository});

  Future<Unit> call(ThemeType theme) async {
    return await repository.saveTheme(theme);
  }
}