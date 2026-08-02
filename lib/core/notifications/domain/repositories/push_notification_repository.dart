import 'package:dartz/dartz.dart';

import '../../../errors/failures.dart';

abstract class PushNotificationRepository {
  /// تهيئة الإشعارات وطلب الصلاحيات
  Future<void> initialize();

  /// جلب توكن الجهاز لإرساله للخادم
  Future<String?> getDeviceToken();

  /// بث (Stream) للاستماع لضغطات المستخدم على الإشعارات
  /// مثلاً ليرجع لنا الـ alert_id الخاص بالغياب أو الدفعة المالية
  Stream<Map<String, dynamic>> get onNotificationTap;

  /// بث جديد: بيصدر حدث فورًا لما يوصل إشعار **والتطبيق مفتوح**
  /// (foreground) — مفيد لتحديث أي بادج/عداد بالواجهة مباشرة، بدون
  /// ما ينتظر المستخدم يضغط عالإشعار.
  Stream<Map<String, dynamic>> get onForegroundMessage;

  Future<Either<Failure, Unit>> PutFcmToken(String fcmToken);

  /// 🕒 جدولـة الإشعار المحلي اليومي التلقائي
  Future<void> scheduleDailyTaskNotification();
}