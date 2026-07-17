import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../models/profile_picture_model.dart';

abstract class ProfileRemoteDataSource {
  Future<String> uploadProfilePicture(File image);

  /// جلب بيانات وصفية إضافية عن الصورة (لو محتاجينها لاحقًا) —
  /// كانت هون بس بدون تعريف بالعقد (سبب خطأ compile)، فضفناها هون.
  Future<ProfilePictureModel> getProfilePictureMetadata();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  const ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> uploadProfilePicture(File image) async {
    try {
      final fileName = p.basename(image.path);

      // 1. تجهيز البيانات للإرسال
      final formData = FormData.fromMap({
        'personal_image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiEndpoints.uploadProfilePicture,
        data: formData,
      );

      final data = response.data;

      String? url;
      if (data is Map) {
        url = data['data']?['photo_url']?.toString() ??
            data['photo_url']?.toString() ??
            data['url']?.toString() ??
            data['data']?['url']?.toString() ??
            data['data']?['personal_image']?.toString() ??
            data['personal_image']?.toString() ??
            data['image_url']?.toString() ??
            data['data']?['image_url']?.toString();
      }

      // التحقق من حالة الطلب ووجود الرابط المستخرج
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300 ||
          url == null) {
        throw const ServerException(message: 'فشل استخراج رابط الصورة المسترجع من السيرفر');
      }

      return url;
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message']?.toString() ?? e.message;
      throw ServerException(message: serverMessage ?? 'حدث خطأ في السيرفر أثناء الرفع');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfilePictureModel> getProfilePictureMetadata() async {
    try {
      // TODO: تأكد هالمسار صحيح فعليًا عند الباك إند، أو احذف هالدالة
      // بالكامل (من هون ومن العقد فوق) لو مش مستخدمة بأي مكان بالمشروع.
      final response = await dio.get('/profile/picture-info');
      if (response.statusCode == 200) {
        return ProfilePictureModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'فشل جلب بيانات الصورة الوصفية');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
