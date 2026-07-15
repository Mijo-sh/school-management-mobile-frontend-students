import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:school_management_mobile_frontend_students/core/errors/failures.dart';
import 'package:school_management_mobile_frontend_students/core/notifications/data/data_sources/remote_data_source/remote_data_source_notification.dart';
import '../../domain/repositories/push_notification_repository.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // يمكنك هنا تسجيل لوج أو التعامل المبدئي مع التنبيه وهو مغلق
}

class FirebasePushNotificationService implements PushNotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationRemoteDataSource remoteDataSource;
  final _notificationTapController = StreamController<Map<String, dynamic>>.broadcast();

  // 👇 بث جديد: بيصدر حدث فورًا لما توصل رسالة والتطبيق مفتوح.
  final _foregroundMessageController = StreamController<Map<String, dynamic>>.broadcast();

  // 👇 صرنا نحتفظ فيها كحقل بالكلاس (مش متغيّر محلي جوا initialize)
  // حتى نقدر نستخدمها لاحقًا جوا onMessage.listen لعرض إشعار فعلي.
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  FirebasePushNotificationService({required this.remoteDataSource});

  @override
  Stream<Map<String, dynamic>> get onNotificationTap => _notificationTapController.stream;

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage => _foregroundMessageController.stream;

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // الـ ID المستخدم في الفايربيز والـ AndroidManifest
      'High Importance Notifications',
      description: 'This channel is used for important school notifications.',
      importance: Importance.max, // الأهمية القصوى لإظهار الكرت بصوت والتطبيق في الخلفية
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // تهيئة أساسية لمكتبة الإشعارات المحلية (لازمة قبل استخدام .show)
   
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
    // ضبط خيارات العرض الافتراضية للفايربيز
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // تسجيل معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // الحالة 1: التطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // 1) نبث الحدث لأي شاشة بالتطبيق مهتمة (متل تحديث البادج الأخضر)
      _foregroundMessageController.add(message.data);

      // 2) نعرض إشعار نظامي فعلي يدويًا — Firebase ما بيعرضه تلقائيًا
      // وقت التطبيق مفتوح، لازم نعرضه إحنا بأنفسنا.
      _showLocalNotification(message);
    });

    // الحالة 2: التطبيق في الخلفية وتم الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _notificationTapController.add(message.data);
    });

    // الحالة 3: التطبيق كان مغلقاً تماماً وتم فتحه عبر الإشعار
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _notificationTapController.add(initialMessage.data);
      });
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // ما في عنوان/نص نعرضه

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important school notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print("خطأ في جلب التوكن: $e");
      return null;
    }
  }

  @override
  Future<Either<Failure, Unit>> PutFcmToken(String fcmToken) async {
    try {
      await remoteDataSource.PutFcmToken(fcmToken);
      return const Right(unit);
    } catch (e) {
      print("خطأ أثناء إرسال FCM Token للسيرفر: $e");
      return Left(ServerFailure());
    }
  }
}