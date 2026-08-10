import 'package:dio/dio.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/alert_item_model.dart';

abstract class AlertRemoteDataSource {
  Future<PaginatedModel<AlertItemModel>> getAlerts({int? studentId, int page = 1});

  Future<int> getUnreadCount({int? studentId});
  Future<void> markAsRead({int? studentId});
}

class AlertRemoteDataSourceImpl extends BaseRemoteDataSource implements AlertRemoteDataSource {
  final Dio dio;
  AlertRemoteDataSourceImpl({required this.dio});

  String _alertsPath(int? studentId) {
    return studentId == null
        ? '/api/user/my-alerts'
        : '/api/user/child-alerts/$studentId';
  }

  @override
  Future<PaginatedModel<AlertItemModel>> getAlerts({int? studentId, int page = 1}) async {
    return execute(() async {
      final response = await dio.get(
        _alertsPath(studentId),
        queryParameters: {'page': page},
      );

      // 3. تمرير نوع البيانات للـ Constructor الموحد PaginatedModel<AlertItemModel> 👇
      return PaginatedModel<AlertItemModel>.fromJson(
        response.data as Map<String, dynamic>,
            (itemJson) => AlertItemModel.fromJson(itemJson as Map<String, dynamic>),
      );
    });

  }

  @override
  Future<int> getUnreadCount({int? studentId}) async {
    return execute(() async {
      final response = await dio.get(
        '/api/user/alerts/unread-count',
        queryParameters: studentId != null ? {'student_id': studentId} : null,
      );
      return (response.data['data']?['alerts'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAsRead({int? studentId}) async {
    return execute(() async {
      await dio.post(
        '/api/user/alerts/mark-all-read',
        queryParameters: studentId != null
            ? {'student_id': studentId, 'category': 'general'}
            : {'category': 'general'},
      );
     });

}
}