// ═══════════════════════════════════════════════════════════════
// هذا snippet توضيحي — يوضّح كيف تعرض إشعار مرئي عند وصول رسالة
// foreground (والتطبيق مفتوح). يوضع في المكان المركزي الذي يستمع
// لـ onForegroundMessage (عادةً حيث تُهيّئ الإشعارات في بداية التطبيق،
// أو داخل PushNotificationRepository implementation).
//
// ملاحظة: هذا مكمّل لـ QuizUnreadStore — الـ store يحدّث العدّاد،
// وهذا الجزء يعرض الإشعار المرئي بالشريط. الاثنان يستمعان لنفس
// الـ stream، كلٌّ لمسؤوليته.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ForegroundNotificationPresenter {
  final FlutterLocalNotificationsPlugin _plugin;

  ForegroundNotificationPresenter(this._plugin);

  // قناة الإشعارات (لازم تُنشأ مرة عند بداية التطبيق على أندرويد)
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'quiz_channel',
    'إشعارات الكويزات',
    description: 'إشعارات الكويزات التدريبية الجديدة',
    importance: Importance.high,
  );

  /// يُستدعى عند وصول رسالة foreground.
  /// [data] هي حمولة الإشعار، و[title]/[body] النص المعروض.
  Future<void> showIfNeeded({
    required Map<String, dynamic> data,
    required String? title,
    required String? body,
  }) async {
    // اعرض إشعار الكويز فقط (يمكن توسيعها لأنواع أخرى)
    final type = data['type']?.toString();
    if (type != 'new_practice_quiz') return;

  //   await _plugin.show(
  //     // id فريد — نستخدم quiz_id لتفادي تكرار نفس الإشعار
  //    // int.tryParse(data['quiz_id']?.toString() ?? '') ?? 0,
  //     title ?? 'كويز جديد',
  //     body ?? 'تمت إضافة كويز تدريبي جديد',
  //     notificationDetails: NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channelDescription: channel.description,
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //       iOS: const DarwinNotificationDetails(
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       ),
  //     ),
  //     // payload لفتح الكويز عند الضغط (اختياري)
  //     payload: data['grade_subject_id']?.toString(), id: 5,
  //   );
  }
}
