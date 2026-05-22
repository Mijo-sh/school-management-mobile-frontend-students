import '../repositories/language_repository.dart';
import '../enums/language_type.dart';
import 'package:dartz/dartz.dart';

class SaveLanguageUseCase {
  final LanguageRepository repository;

  SaveLanguageUseCase({required this.repository});

  Future<Unit> call(LanguageType language) async {
    return await repository.saveLanguage(language);
  }
}