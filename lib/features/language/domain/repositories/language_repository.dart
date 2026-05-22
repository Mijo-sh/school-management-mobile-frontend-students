import '../enums/language_type.dart';
import 'package:dartz/dartz.dart';

abstract class LanguageRepository {
  Future<LanguageType> getLanguage();
  Future<Unit> saveLanguage(LanguageType language);
}