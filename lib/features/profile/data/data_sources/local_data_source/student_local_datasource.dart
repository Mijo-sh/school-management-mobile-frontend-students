import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/student_model.dart';

abstract class StudentLocalDataSource {
  Future<void> cacheAcademicInfo(AcademicInfoModel info);
  Future<AcademicInfoModel?> getCachedAcademicInfo();
}

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final SharedPreferences sharedPreferences;

  StudentLocalDataSourceImpl({required this.sharedPreferences});

  static const CACHE_KEY = 'CACHE_STUDENT_INFO';

  @override
  Future<void> cacheAcademicInfo(AcademicInfoModel info) async {
    await sharedPreferences.setString(CACHE_KEY, jsonEncode(info.toJson()));
  }

  @override
  Future<AcademicInfoModel?> getCachedAcademicInfo() async {
    final jsonString = sharedPreferences.getString(CACHE_KEY);
    if (jsonString != null) {
      return AcademicInfoModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }
}