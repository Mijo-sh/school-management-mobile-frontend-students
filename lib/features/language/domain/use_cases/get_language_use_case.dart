import '../repositories/language_repository.dart';
import '../enums/language_type.dart';

class GetLanguageUseCase {
  final LanguageRepository repository;

  GetLanguageUseCase({required this.repository});

  Future<LanguageType> call() async {
    return await repository.getLanguage();
  }
}