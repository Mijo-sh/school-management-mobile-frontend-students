import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';

abstract class ProfileLocalDataSource {
  /// ينسخ [image] إلى مجلد الوثائق الخاص بالتطبيق (يبقى موجود حتى بعد
  /// إغلاق التطبيق، بعكس مجلد الكاش المؤقت)، ويخزّن مساره بالـ
  /// SharedPreferences، ويرجع المسار الجديد.
  Future<String> saveProfilePicture(File image);

  /// يرجع المسار المخزَّن إن كان الملف ما زال موجودًا فعليًا على القرص،
  /// وإلا يرجع null (مثلاً لو انحذف يدويًا أو تغيّر مجلد التطبيق).
  Future<String?> getProfilePicturePath();

  /// يحذف الملف الفعلي من التخزين بالإضافة لمسحه من SharedPreferences.
  Future<void> deleteProfilePicture();

  /// يخزّن رابط السيرفر بعد نجاح الرفع (يُستدعى من الـ repository).
  Future<void> saveRemoteUrl(String url);

  /// يرجع رابط السيرفر المخزَّن سابقًا إن وُجد.
  Future<String?> getRemoteUrl();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const _kProfilePictureKey = 'PROFILE_PICTURE_PATH';
  static const _kProfilePictureRemoteUrlKey = 'PROFILE_PICTURE_REMOTE_URL';

  final SharedPreferences sharedPreferences;

  const ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String> saveProfilePicture(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extension = p.extension(image.path); // مثال: .jpg
      final fileName = 'profile_picture$extension';
      final destinationPath = p.join(appDir.path, fileName);

      // احذف أي صورة قديمة بنفس المسار قبل النسخ لتفادي التعارض.
      final destinationFile = File(destinationPath);
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }

      final savedImage = await image.copy(destinationPath);
      await sharedPreferences.setString(_kProfilePictureKey, savedImage.path);

      return savedImage.path;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getProfilePicturePath() async {
    try {
      final path = sharedPreferences.getString(_kProfilePictureKey);
      if (path == null) return null;

      final fileExists = await File(path).exists();
      return fileExists ? path : null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteProfilePicture() async {
    try {
      final path = sharedPreferences.getString(_kProfilePictureKey);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await sharedPreferences.remove(_kProfilePictureKey);
      await sharedPreferences.remove(_kProfilePictureRemoteUrlKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveRemoteUrl(String url) async {
    try {
      await sharedPreferences.setString(_kProfilePictureRemoteUrlKey, url);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getRemoteUrl() async {
    try {
      return sharedPreferences.getString(_kProfilePictureRemoteUrlKey);
    } catch (e) {
      throw CacheException();
    }
  }
}