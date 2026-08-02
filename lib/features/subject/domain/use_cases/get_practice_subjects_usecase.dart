import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subject_entity.dart';
import '../repositories/subjects_repository.dart';

class GetPracticeSubjectsUseCase {
  final SubjectsRepository repository;

  GetPracticeSubjectsUseCase(this.repository);

  Future<Either<Failure, List<SubjectEntity>>> call() async {
    return await repository.getPracticeSubjects();
  }
}