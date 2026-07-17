import 'package:flutter/material.dart';
import '../../domain/repositories/push_notification_repository.dart';

class NotificationHandler {
  final PushNotificationRepository _notificationRepository;

  NotificationHandler(this._notificationRepository);

  void listenForRoutes(BuildContext context) {
    _notificationRepository.onNotificationTap.listen((data) {
      // استخراج نوع التنبيه والمعرف القادمين من Laravel
      final alertType = data['alert_type'];
      final alertId = data['alert_id'];

      if (alertType != null && alertId != null) {
        _navigateToScreen(context, alertType, alertId);
      }
    });
  }

  void _navigateToScreen(BuildContext context, String type, String id) {
    // توجيه بناءً على نوع التنبيه في النظام المدرسي
    switch (type) {
      case 'absence':
        print("توجيه لشاشة الغياب: $id");
        break;
      case 'fee_payment':
        print("توجيه للمحفظة: $id");
        break;
      default:
      // التوجيه الافتراضي
        break;
    }
  }
}
