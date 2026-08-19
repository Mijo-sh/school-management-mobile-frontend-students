import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/top_student.dart';
abstract class TopStudentsRepository {
  Future<Either<Failure, List<TopStudent>>> getTopStudents({
    required int semesterId,
    int? studentId,
  });
}