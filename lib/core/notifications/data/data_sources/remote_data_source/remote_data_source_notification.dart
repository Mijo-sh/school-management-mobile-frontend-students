import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../../../errors/exceptions.dart';

abstract class NotificationRemoteDataSource {
  Future<Unit> PutFcmToken(String fcmToken);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio; // الـ Dio الممرر هنا يجب أن يكون محقوناً بالـ Interceptor الخاص بك

  NotificationRemoteDataSourceImpl({required this.dio});
  @override
  Future<Unit> PutFcmToken(String fcmToken) async {
    try {
      final response = await dio.post(
        '/api/user/device-tokens',
        data: {
          'fcm token': fcmToken,
        },
        queryParameters: {
          'fcm token': fcmToken,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return unit;
      } else {
        throw ServerException(message: 'فشل تحديث توكن الإشعارات');
      }
    } on DioException catch (e) {
      print("❌ [FCM Error]: ${e.response?.data}");
      throw ServerException(message: 'خطأ في خادم الإشعارات');
    }
  }
}