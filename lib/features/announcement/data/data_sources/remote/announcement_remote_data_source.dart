import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/announcement_item_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementItemModel>> getAnnouncements({int? studentId});

  /// endpoint حقيقي وواحد للدورين (student_id اختياري يميّز بينهم).
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAsRead({int? studentId});
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final Dio dio;
  AnnouncementRemoteDataSourceImpl({required this.dio});

  // المسارات منفصلة بالكامل حسب الدور — my-announcements للطالب
  // (بدون أي parameter)، child-announcements لولي الأمر (مع
  // student_id اختياري كـ query parameter، مش جزء من الرابط).
  String _path(int? studentId) {
    return studentId == null
        ? '/api/user/my-announcements'
        : '/api/user/child-announcements';
  }

  @override
  Future<List<AnnouncementItemModel>> getAnnouncements({int? studentId}) async {
    try {
      final response = await dio.get(
        _path(studentId),
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );

      final list = (response.data['data'] as List<dynamic>? ?? []);
      return list
          .map((e) => AnnouncementItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    try {
      final response = await dio.get(
        '/api/user/announcements/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      return (response.data['data']?['count'] as num?)?.toInt() ?? 0;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead({int? studentId}) async {
    try {
      await dio.post(
        '/api/user/announcements/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}