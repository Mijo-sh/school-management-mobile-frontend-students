import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/top_student.dart';
import '../repositories/top_students_repository.dart';

class GetTopStudentsUseCase {
  final TopStudentsRepository repository;
  const GetTopStudentsUseCase({required this.repository});

  Future<Either<Failure, List<TopStudent>>> call({
    required int semesterId,
    int? studentId,
  }) {
    return repository.getTopStudents(
      semesterId: semesterId,
      studentId: studentId,
    );
  }
}