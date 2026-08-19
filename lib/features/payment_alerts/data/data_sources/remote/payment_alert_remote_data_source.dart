import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/payment_alert_item_model.dart';

abstract class PaymentAlertRemoteDataSource {
  Future<PaginatedModel<PaymentAlertItemModel>> getAlerts({
    int? studentId,
    int page = 1,
  });

  Future<int> getUnreadCount({int? studentId});
  Future<void> markAsRead({int? studentId});
}

class PaymentAlertRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PaymentAlertRemoteDataSource {
  final Dio dio;
  PaymentAlertRemoteDataSourceImpl({required this.dio});

  String _alertsPath(int? studentId) {
    // ⚠️ endpoint المستخدم الحالي (بدون studentId) ما بعتّه لي —
    // حطّيت تخمين معقول. عدّلو لو المسار عندك مختلف.
    return studentId == null
        ? '/api/user/my-payment-alerts'
        : '/api/user/payment-alerts/$studentId';
  }

  @override
  Future<PaginatedModel<PaymentAlertItemModel>> getAlerts({
    int? studentId,
    int page = 1,
  }) async {
    return execute(() async {
      final response = await dio.get(
        _alertsPath(studentId),
        queryParameters: {'page': page},
      );

      return PaginatedModel<PaymentAlertItemModel>.fromJson(
        response.data as Map<String, dynamic>,
            (itemJson) =>
            PaymentAlertItemModel.fromJson(itemJson as Map<String, dynamic>),
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
      // الفرق هون: منقرا payment_alerts بدل alerts
      return (response.data['data']?['payment_alerts'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAsRead({int? studentId}) async {
    return execute(() async {
      await dio.post(
        '/api/user/alerts/mark-all-read',
        queryParameters: studentId != null
            ? {'student_id': studentId, 'category': 'financial'}
            : {'category': 'financial'},
      );
    });
  }
}