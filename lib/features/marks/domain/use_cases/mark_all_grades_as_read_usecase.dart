import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/grade_repository.dart';

class MarkAllGradesAsReadUseCase {
  final GradeRepository repository;
  const MarkAllGradesAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAllAsRead(studentId: studentId);
  }
}