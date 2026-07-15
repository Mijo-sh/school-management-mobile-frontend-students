// core/notifications/domain/use_cases/update_fcm_token_on_server_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../errors/failures.dart';
import '../repositories/push_notification_repository.dart';

class PutFcmTokenUseCase {
  final PushNotificationRepository repository;

  PutFcmTokenUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String fcmToken) async {
    return await repository.PutFcmToken(fcmToken);
  }
}