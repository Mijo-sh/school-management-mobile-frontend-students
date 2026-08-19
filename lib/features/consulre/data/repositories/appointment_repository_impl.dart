// data/repositories/appointment_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/available_slot.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../data_sources/remote/appointment_remote_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  const AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AvailableSlot>>> getAvailableSlots() async {
    try {
      final slots = await remoteDataSource.getAvailableSlots();
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getMyAppointments() async {
    try {
      final list = await remoteDataSource.getMyAppointments();
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure());
    }
  }
  @override
  Future<Either<Failure, Unit>> bookAppointment({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await remoteDataSource.bookAppointment(
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } on UnexpectedException catch (_) {
      return Left(UnExpectedFailure()); // ✅ يرجّع بدل يرمي
    }
  }
  @override
  Future<Either<Failure, Unit>> cancelAppointment({required int id}) async {
    try {
      await remoteDataSource.cancelAppointment(id: id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure());
    }
  }
}