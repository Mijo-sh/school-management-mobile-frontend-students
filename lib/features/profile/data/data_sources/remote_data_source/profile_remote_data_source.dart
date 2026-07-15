import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_endpoints.dart';

abstract class ProfileRemoteDataSource {
  /// يرفع [image] للسيرفر ويرجع رابط الصورة النهائي بعد الرفع.
  Future<String> uploadProfilePicture(File image);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  const ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> uploadProfilePicture(File image) async {
    try {
      final fileName = p.basename(image.path);
      final formData = FormData.fromMap({
        // TODO: تأكد إنو اسم الحقل "profile_picture" مطابق لما يتوقعه الـ backend.
        'profile_picture': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        // TODO: عدّل الرابط بملف core/constants/api_constants.dart
        ApiEndpoints.uploadProfilePicture,
        data: formData,
      );

      // TODO: عدّل طريقة استخراج الرابط حسب شكل استجابة الـ backend الفعلي.
      // أمثلة شائعة: response.data['url'] أو response.data['data']['url']
      final data = response.data;
      final url = (data is Map)
          ? (data['url'] ?? data['data']?['url'])
          : null;

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300 ||
          url == null) {
        throw const ServerException();
      }

      return url as String;
    } on DioException catch (e) {
      throw ServerException();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException();
    }
  }
}
