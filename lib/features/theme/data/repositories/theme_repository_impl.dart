import '../../domain/repositories/theme_repository.dart';
import '../data_sources/theme_local_data_source.dart';
import '../../domain/enums/theme_type.dart';
import 'package:dartz/dartz.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl({required this.localDataSource});

  @override
  Future<ThemeType> getTheme() async {
    var theme = await localDataSource.getCachedTheme();
    return theme;
  }

  @override
  Future<Unit> saveTheme(ThemeType theme) async {
    await localDataSource.cacheTheme(theme);
    return Future.value(unit);
  }
}