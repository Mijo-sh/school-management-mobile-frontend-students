import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/report_card_model.dart';

abstract class ReportCardLocalDataSource {
  Future<void> cacheReportCard(ReportCardModel reportCard,
      {int? studentId, int? reportCardId});

  Future<ReportCardModel> getCachedReportCard(
      {int? studentId, int? reportCardId});
}

class ReportCardLocalDataSourceImpl implements ReportCardLocalDataSource {
  final SharedPreferences sharedPreferences;
  const ReportCardLocalDataSourceImpl({required this.sharedPreferences});

  String _keyFor(int? studentId, int? reportCardId) =>
      'CACHED_REPORT_CARD_${studentId?.toString() ?? 'self'}_${reportCardId?.toString() ?? 'latest'}';

  @override
  Future<void> cacheReportCard(ReportCardModel reportCard,
      {int? studentId, int? reportCardId}) async {
    try {
      final jsonString = jsonEncode(reportCard.toJson());
      await sharedPreferences.setString(
          _keyFor(studentId, reportCardId), jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<ReportCardModel> getCachedReportCard(
      {int? studentId, int? reportCardId}) async {
    final jsonString =
    sharedPreferences.getString(_keyFor(studentId, reportCardId));
    if (jsonString == null) {
      throw EmptyCacheException();
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ReportCardModel.fromJson(map);
    } catch (e) {
      throw CacheException();
    }
  }
}