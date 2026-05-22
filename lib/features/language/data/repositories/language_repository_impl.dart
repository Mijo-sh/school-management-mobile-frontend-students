import '../../domain/repositories/language_repository.dart';
import '../data_sources/language_local_data_source.dart';
import '../../domain/enums/language_type.dart';
import 'package:dartz/dartz.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDataSource localDataSource;

  LanguageRepositoryImpl({required this.localDataSource});

  @override
  Future<LanguageType> getLanguage() async {
    var language = await localDataSource.getCachedLanguage();
    return language;
  }

  @override
  Future<Unit> saveLanguage(LanguageType language) async {
    await localDataSource.cacheLanguage(language);
    return Future.value(unit);
  }
}