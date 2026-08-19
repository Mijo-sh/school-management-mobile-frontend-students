// domain/use_cases/cancel_appointment_use_case.dart
import '../../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';
import 'package:dartz/dartz.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;
  const CancelAppointmentUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({required int id}) async {
    return await repository.cancelAppointment(id: id);
  }
}