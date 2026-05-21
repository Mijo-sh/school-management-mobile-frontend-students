import '../repositories/theme_repository.dart';
import '../enums/theme_type.dart';

class GetThemeUseCase {
  final ThemeRepository repository;

  GetThemeUseCase({required this.repository});

  Future<ThemeType> call() async {
    return await repository.getTheme();
  }
}