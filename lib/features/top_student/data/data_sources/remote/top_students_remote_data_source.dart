import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/top_student_model.dart';

abstract class TopStudentsRemoteDataSource {
  Future<List<TopStudentModel>> getTopStudents({
    required int semesterId,
    int? studentId,
  });
}

class TopStudentsRemoteDataSourceImpl extends BaseRemoteDataSource
    implements TopStudentsRemoteDataSource {
  final Dio dio;
  TopStudentsRemoteDataSourceImpl({required this.dio});

  // اختيار المسار حسب وجود studentId (أب) أو لا (طالب)
  String _path(int? studentId) {
    return studentId == null
        ? '/api/student/report-cards/top-students'
        : '/api/parent/report-cards/top-students';
  }
  @override
  Future<List<TopStudentModel>> getTopStudents({
    required int semesterId,
    int? studentId,
  }) async {
    return execute(() async {
      debugPrint(
          "🚀 [TopStudents] جلب الأوائل | semesterId: $semesterId | studentId: $studentId");

      final Map<String, dynamic> data = {'semester_id': semesterId};
      if (studentId != null) {
        data['student_id'] = studentId;
      }

      debugPrint("📤 [TopStudents] path: ${_path(studentId)} | body: $data");

      try {
        final response = await dio.get(
          _path(studentId),
          data: data,
        );

        debugPrint("✅ [TopStudents] status: ${response.statusCode}");
        debugPrint("✅ [TopStudents] الرد: ${response.data}");

        final body = response.data;
        if (body is Map && body['status'] == false) {
          throw ServerException(
            message: body['message']?.toString() ?? 'فشل جلب الأوائل',
          );
        }

        final list = (body['data'] as List<dynamic>?) ?? [];
        return list
            .map((e) => TopStudentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } on DioException catch (e) {
        // 👇 طباعة تشخيصية مؤقتة
        debugPrint("🚨 [TopStudents] status: ${e.response?.statusCode}");
        debugPrint("🚨 [TopStudents] data: ${e.response?.data}");
        rethrow; // نخلي execute تكمل معالجتها
      }
    });
  }
}