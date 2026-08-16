// lib/features/complaint/domain/use_cases/create_complaint_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/complaint_entities.dart';
import '../repositories/complaint_repository.dart';

class CreateComplaintUseCase {
  final ComplaintRepository repository;
  CreateComplaintUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ComplaintToCreate complaint) {
    return repository.createComplaint(complaint);
  }
}
