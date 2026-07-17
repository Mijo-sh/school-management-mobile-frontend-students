import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';

abstract class ProfilePhotoRemoteDataSource {
  Future<String?> getPhotoUrl({int? studentId});
}

class ProfilePhotoRemoteDataSourceImpl implements ProfilePhotoRemoteDataSource {
  final Dio dio;
  ProfilePhotoRemoteDataSourceImpl({required this.dio});

  // null = صورة المستخدم نفسو، موجود = صورة ابن معيّن (ولي أمر).
  // لاحظ هون الـ id جزء من المسار (path)، مش query parameter —
  // خلاف نمط alerts/announcements (تأكدنا منه فعليًا من الـ endpoint
  // يلي بعته المستخدم: /api/user/guardian/student/{id}/photo).
  String _path(int? studentId) {
    return studentId == null
        ? '/api/auth/personal-image-url'
        : '/api/user/guardian/student/$studentId/photo';
  }

  @override
  Future<String?> getPhotoUrl({int? studentId}) async {
    try {
      final response = await dio.get(_path(studentId));
      final data = response.data['data'] as Map<String, dynamic>?;
      return data?['photo_url'] as String?;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
