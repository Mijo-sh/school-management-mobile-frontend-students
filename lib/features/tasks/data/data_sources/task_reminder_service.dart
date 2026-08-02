import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/random_task.dart';


/// مسؤول عن جدولة/إلغاء إشعار محلي فعلي بيوم كل مهمة — قناة مستقلة
/// كليًا عن نظام إشعارات FCM الموجود، حتى ما نلمس ولا نعقّد الكود
/// الأصلي.
class TaskReminderService {
  static const _channelId = 'random_tasks_channel';
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Damascus'));

    const channel = AndroidNotificationChannel(
      _channelId,
      'تذكير المهام',
      description: 'تذكير يومي بمهام الطالب المضافة يدويًا',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: initSettings);

    _initialized = true;
  }

  /// يجدول إشعار الساعة 8 صباحًا بيوم المهمة. لو الموعد فات (بالماضي)،
  /// ما بيجدول شي (لا فايدة من إشعار لتاريخ فات).
  Future<void> scheduleReminder(RandomTask task) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime(tz.local, task.date.year, task.date.month, task.date.day, 8, 0);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: task.id.hashCode,
      title: 'تذكير بمهمة اليوم 📌',
      body: task.title,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'تذكير المهام',
          channelDescription: 'تذكير يومي بمهام الطالب المضافة يدويًا',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String taskId) async {
    await _ensureInitialized();
    await _plugin.cancel(id: taskId.hashCode);
  }
}