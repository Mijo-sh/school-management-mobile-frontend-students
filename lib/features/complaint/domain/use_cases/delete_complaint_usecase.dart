import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/complaint_repository.dart';

class DeleteComplaintUseCase {
  final ComplaintRepository repository;
  DeleteComplaintUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int complaintId) {
    return repository.deleteComplaint(complaintId);
  }
}