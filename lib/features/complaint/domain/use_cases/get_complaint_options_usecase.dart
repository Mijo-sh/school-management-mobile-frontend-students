// lib/features/complaint/domain/use_cases/get_complaint_options_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/complaint_entities.dart';
import '../repositories/complaint_repository.dart';

class GetComplaintOptionsUseCase {
  final ComplaintRepository repository;
  GetComplaintOptionsUseCase(this.repository);

  Future<Either<Failure, List<ComplaintCategory>>> call() {
    return repository.getOptions();
  }
}
