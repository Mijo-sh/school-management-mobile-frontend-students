import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/school_rule.dart';
import '../repositories/school_rules_repository.dart';

class GetSchoolRulesUseCase {
  final SchoolRulesRepository repository;

  GetSchoolRulesUseCase(this.repository);

  Future<Either<Failure, List<SchoolRule>>> call() async {
    return await repository.getSchoolRules();
  }
}