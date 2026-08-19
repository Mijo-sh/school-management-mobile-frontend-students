// domain/use_cases/get_available_slots_use_case.dart
import '../../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';
import '../entities/available_slot.dart';
import 'package:dartz/dartz.dart';

class GetAvailableSlotsUseCase {
  final AppointmentRepository repository;
  const GetAvailableSlotsUseCase({required this.repository});

  Future<Either<Failure, List<AvailableSlot>>> call() async {
    return await repository.getAvailableSlots();
  }
}