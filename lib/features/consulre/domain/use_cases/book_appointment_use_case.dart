// domain/use_cases/book_appointment_use_case.dart
import '../../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';
import 'package:dartz/dartz.dart';

class BookAppointmentUseCase {
  final AppointmentRepository repository;
  const BookAppointmentUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    return await repository.bookAppointment(
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }
}