// domain/use_cases/get_my_appointments_use_case.dart
import '../../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';
import '../entities/appointment.dart';
import 'package:dartz/dartz.dart';

class GetMyAppointmentsUseCase {
  final AppointmentRepository repository;
  const GetMyAppointmentsUseCase({required this.repository});

  Future<Either<Failure, List<Appointment>>> call() async {
    return await repository.getMyAppointments();
  }
}