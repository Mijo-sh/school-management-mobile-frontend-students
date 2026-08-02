import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/grade_item.dart';
import '../repositories/grade_repository.dart';

class GetGradesUseCase {
  final GradeRepository repository;
  const GetGradesUseCase({required this.repository});

  Future<Either<Failure, Paginated<GradeItem>>> call({int? studentId, int page = 1}) {
    return repository.getGrades(studentId: studentId, page: page);
  }
}