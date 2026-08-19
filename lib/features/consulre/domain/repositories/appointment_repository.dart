// domain/repositories/appointment_repository.dart
import '../../../../../core/errors/failures.dart';
import '../entities/available_slot.dart';
import '../entities/appointment.dart';
import 'package:dartz/dartz.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<AvailableSlot>>> getAvailableSlots();
  Future<Either<Failure, List<Appointment>>> getMyAppointments();
  Future<Either<Failure, Unit>> bookAppointment({
    required String date,
    required String startTime,
    required String endTime,
  });
  Future<Either<Failure, Unit>> cancelAppointment({required int id});
}