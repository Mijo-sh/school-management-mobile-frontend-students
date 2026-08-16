// lib/features/complaint/domain/use_cases/get_complaints_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/complaint_entities.dart';
import '../repositories/complaint_repository.dart';

class GetComplaintsUseCase {
  final ComplaintRepository repository;
  GetComplaintsUseCase(this.repository);

  Future<Either<Failure, List<Complaint>>> call(int studentId) {
    return repository.getComplaints(studentId);
  }
}
