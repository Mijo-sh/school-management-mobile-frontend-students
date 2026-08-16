// lib/features/exam/data/data_sources/remote/exam_schedule_remote_data_source.dart

import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../../domain/entities/exam_schedule_entity.dart';
import '../../../domain/entities/exam_unread_counts.dart';
import '../../models/exam_schedule_model.dart';

abstract class ExamScheduleRemoteDataSource {
  /// يرجّع كل البنود (مذاكرة + امتحان) دفعة واحدة.
  /// studentId: يُرسل فقط لولي الأمر (الطالب لا يحتاجه).
  Future<List<ExamScheduleModel>> getExamSchedule({int? studentId});

  /// عدّادات غير المقروء مفصولة (امتحانات + مذاكرات).
  Future<ExamUnreadCounts> getUnreadCounts({int? studentId});

  /// تعليم بنود نوع معيّن (quiz أو exam) كمقروءة.
  Future<void> markAllAsRead({required ExamType type, int? studentId});
}

class ExamScheduleRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ExamScheduleRemoteDataSource {
  final Dio dio;

  ExamScheduleRemoteDataSourceImpl({required this.dio});

  Map<String, dynamic>? _params(int? studentId) =>
      studentId != null ? {'student_id': studentId} : null;

  @override
  Future<List<ExamScheduleModel>> getExamSchedule({int? studentId}) {
    return execute(() async {
      final response = await dio.get(
        '/api/user/exam/schedule/show',
        queryParameters: _params(studentId),
      );
      final data = response.data['data'] as List;
      return data
          .map((json) => ExamScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<ExamUnreadCounts> getUnreadCounts({int? studentId}) {
    return execute(() async {
      final response = await dio.get(
        '/api/user/exam/schedule/unread/count',
        queryParameters: _params(studentId),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ExamUnreadCounts(
        exams: (data['exams_count'] as num?)?.toInt() ?? 0,
        quizzes: (data['quizzes_count'] as num?)?.toInt() ?? 0,
      );
    });
  }

  @override
  Future<void> markAllAsRead({required ExamType type, int? studentId}) {
    return execute(() async {
      await dio.post(
        '/api/user/exam/schedule/mark/all/read',
        queryParameters: {
          'type': type.apiValue,
          if (studentId != null) 'student_id': studentId,
        },
      );
    });
  }
}
