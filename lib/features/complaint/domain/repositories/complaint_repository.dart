// lib/features/complaint/domain/repositories/complaint_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/complaint_entities.dart';

abstract class ComplaintRepository {
  Future<Either<Failure, List<ComplaintCategory>>> getOptions();
  Future<Either<Failure, List<Complaint>>> getComplaints(int studentId);
  Future<Either<Failure, Unit>> createComplaint(ComplaintToCreate complaint);
  Future<Either<Failure, Unit>> deleteComplaint(int complaintId); // 👈 جديد

}
