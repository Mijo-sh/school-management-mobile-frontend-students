import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_mobile_frontend_students/main.dart';
import 'package:school_management_mobile_frontend_students/core/notifications/domain/repositories/push_notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/core/errors/failures.dart';

class FakeNotificationService implements PushNotificationRepository {
  @override
  Future<void> initialize() async {
  }

  @override
  Future<String?> getDeviceToken() async {
    return "fake-token";
  }

  @override
  Stream<Map<String, dynamic>> get onNotificationTap => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage => const Stream.empty();

  @override
  Future<Either<Failure, Unit>> PutFcmToken(String fcmToken) async {
    return const Right(unit);
  }

  @override
  Future<void> scheduleDailyTaskNotification() async {
    // تنفيذ وهمي للاختبارات
  }
}
void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final fakeService = FakeNotificationService();

    await tester.pumpWidget(
      MyApp(notificationService: fakeService),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app_material_app')), findsWidgets);
     expect(find.byType(MaterialApp), findsOneWidget);
  });
}