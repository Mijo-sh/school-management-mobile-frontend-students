import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_picture.dart';

abstract class ProfileRepository {
  /// رفع صورة جديدة — دايمًا لصورة المستخدم الحالي نفسو (ما في مفهوم
  /// "ارفع صورة لابن" أصلًا).
  Future<Either<Failure, ProfilePicture>> saveProfilePicture(File image);

  /// النسخة المحفوظة محليًا (مسار الملف + آخر رابط سيرفر معروف).
  Future<Either<Failure, ProfilePicture?>> getProfilePicture();

  Future<Either<Failure, void>> deleteProfilePicture();

  /// رابط الصورة الحقيقي من السيرفر — للعرض بأي مكان بالتطبيق.
  /// [studentId] اختياري: null = صورة المستخدم نفسو، موجود = صورة
  /// ابن معيّن (ولي أمر).
  Future<Either<Failure, String?>> getPhotoUrl({int? studentId});
}
