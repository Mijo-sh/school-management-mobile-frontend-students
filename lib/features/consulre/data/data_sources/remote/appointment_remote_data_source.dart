// data/data_sources/appointment_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/appointment_model.dart';
import '../../models/available_slot_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AvailableSlotModel>> getAvailableSlots();
  Future<List<AppointmentModel>> getMyAppointments();
  Future<void> bookAppointment({
    required String date,
    required String startTime,
    required String endTime,
  });
  Future<void> cancelAppointment({required int id});
}

class AppointmentRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AppointmentRemoteDataSource {
  final Dio dio;

  AppointmentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AvailableSlotModel>> getAvailableSlots() {
    return execute(() async {
      final response = await dio.get('/api/user/counselor/available/slot');
      final data = response.data['data'] as List;
      return data
          .map((json) =>
          AvailableSlotModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<AppointmentModel>> getMyAppointments() {
    return execute(() async {
      final response = await dio.get('/api/user/get/my/appointments');
      final data = response.data['data'] as List;
      return data
          .map((json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
  @override
  Future<void> bookAppointment({
    required String date,
    required String startTime,
    required String endTime,
  }) {
    return execute(() async {
      await dio.post(
        '/api/user/counselor/counseling/appointments',
        data: {
          'appointment_date': date,
          'start_time': startTime,
          'end_time': endTime,
        },
      );
    });
  }
  @override
  Future<void> cancelAppointment({required int id}) {
    return execute(() async {
      await dio.delete('/api/user/counselor/cancel/$id');
    });
  }
}