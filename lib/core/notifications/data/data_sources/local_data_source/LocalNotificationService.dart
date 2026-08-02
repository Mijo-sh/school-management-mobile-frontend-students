
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // التعامل مع الضغط على الإشعار
      },
      settings: initializationSettings,
    );
  }

  // دالة لجدولة الإشعار ليظهر في ساعة ودقيقة معينة كل يوم
  static Future<void> scheduleDailyAtSpecificTime({
    required int id,
    required String title,
    required String body,
    required int hour,   // الساعة بنظام 24 ساعة (مثلاً 8 صباحاً = 8)
    required int minute, // الدقيقة
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_task_channel_id',
          'المهام اليومية',
          channelDescription: 'قناة خاصة بتذكيرات المهام اليومية',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // لتكرار الإشعار يومياً في نفس الوقت تماماً
    );
  }

  // إيقاف إشعار معين إذا لزم الأمر
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}