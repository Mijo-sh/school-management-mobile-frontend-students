import '../../data/data_sources/local_data_source/notification_local_data_source.dart';
import '../repositories/push_notification_repository.dart';

class EnsureFcmTokenUseCase {
  final PushNotificationRepository _pushRepository;
  final NotificationLocalDataSource _localStorage;

  EnsureFcmTokenUseCase(this._pushRepository, this._localStorage);

  Future<String?> call() async {
    final cachedToken = await _localStorage.getFcmToken();
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return cachedToken;
    }

    final newToken = await _pushRepository.getDeviceToken();
    if (newToken != null) {
      await _localStorage.saveFcmToken(newToken);
    }
    return newToken;
  }
}