import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/announcement_item_model.dart';

abstract class AnnouncementLocalDataSource {
  Future<void> cacheAnnouncements(List<AnnouncementItemModel> announcements, {int? studentId});

  Future<List<AnnouncementItemModel>> getCachedAnnouncements({int? studentId});
}

class AnnouncementLocalDataSourceImpl implements AnnouncementLocalDataSource {
  final SharedPreferences sharedPreferences;
  const AnnouncementLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId) =>
      'CACHED_ANNOUNCEMENTS_${studentId?.toString() ?? 'self'}';

  @override
  Future<void> cacheAnnouncements(List<AnnouncementItemModel> announcements, {int? studentId}) async {
    try {
      final jsonString = jsonEncode(announcements.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(_keyFor(studentId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AnnouncementItemModel>> getCachedAnnouncements({int? studentId}) async {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) {
      throw  throw EmptyCacheException();
    }
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => AnnouncementItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }
}
