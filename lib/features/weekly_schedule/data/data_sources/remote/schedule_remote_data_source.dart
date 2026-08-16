import 'package:dio/dio.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/schedule_entry_model .dart';

abstract class ScheduleRemoteDataSource {
  Future<Map<String, List<ScheduleEntryModel>>> getWeeklySchedule(int? studentId);
  Future<Map<String, List<ScheduleEntryModel>>> getTomorrowSchedule(int? studentId);
}

class ScheduleRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ScheduleRemoteDataSource {
  final Dio dio;
  ScheduleRemoteDataSourceImpl({required this.dio});

  Map<String, List<ScheduleEntryModel>> _parse(Response response) {
    final data = response.data['data'] as Map<String, dynamic>;
    return data.map((day, entriesJson) {
      final entries = (entriesJson as List)
          .map((e) => ScheduleEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(day, entries);
    });
  }

  // studentId يُرسل كـ query param فقط عند وجوده (ولي الأمر)، والطالب يتركه null.
  Map<String, dynamic>? _params(int? studentId) =>
      studentId != null ? {'student_id': studentId} : null;

  @override
  Future<Map<String, List<ScheduleEntryModel>>> getWeeklySchedule(int? studentId) {
    return execute(() async {
      final response = await dio.get(
        '/api/user/schedules/all',
        queryParameters: _params(studentId),
      );
      return _parse(response);
    });
  }

  @override
  Future<Map<String, List<ScheduleEntryModel>>> getTomorrowSchedule(int? studentId) {
    return execute(() async {
      final response = await dio.get(
        '/api/user/schedules/tomorrow',
        queryParameters: _params(studentId),
      );
      return _parse(response);
    });
  }
}