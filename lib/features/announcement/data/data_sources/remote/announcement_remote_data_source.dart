import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/announcement_item_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<PaginatedModel<AnnouncementItemModel>> getAnnouncements({int? studentId, int page = 1});

  /// endpoint حقيقي وواحد للدورين (student_id اختياري يميّز بينهم).
  Future<int> getUnreadCount({int? studentId});
  Future<void> markAsRead({int? studentId});
}

class AnnouncementRemoteDataSourceImpl extends BaseRemoteDataSource implements AnnouncementRemoteDataSource {
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
  Future<PaginatedModel<AnnouncementItemModel>> getAnnouncements(
      {int? studentId, int page = 1}) async {
    return execute(() async {
      final response = await dio.get(
        _path(studentId),
        queryParameters: {'page': page},
      );

      // تفكيك الـ JSON واستدعاء الـ Factory الموحد للـ Announcement 👈
      return PaginatedModel<AnnouncementItemModel>.fromJson(
        response.data as Map<String, dynamic>,
            (itemJson) =>
            AnnouncementItemModel.fromJson(itemJson as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    return execute(() async {
      final response = await dio.get(
        '/api/user/announcements/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      return (response.data['data']?['count'] as num?)?.toInt() ?? 0;    });
}

  @override
  Future<void> markAsRead({int? studentId}) async {
    return execute(() async {
      await dio.post(
        '/api/user/announcements/mark-all-read',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
    });
  }
}