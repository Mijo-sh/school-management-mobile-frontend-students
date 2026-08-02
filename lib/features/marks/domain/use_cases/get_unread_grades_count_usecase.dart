import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/grade_repository.dart';

class GetUnreadGradesCountUseCase {
  final GradeRepository repository;
  const GetUnreadGradesCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}