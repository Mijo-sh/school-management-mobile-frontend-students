import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/report_card_model.dart';

/// نتيجة الجلاء: إمّا فيها كارد، أو reportCard=null مع رسالة الباك للعرض.
class ReportCardResult {
  final ReportCardModel? reportCard; // null → لا يوجد جلاء
  final String message; // رسالة الباك (تُعرض وقت الفراغ)
  const ReportCardResult({this.reportCard, required this.message});

  bool get isEmpty => reportCard == null;
}

abstract class ReportCardRemoteDataSource {
  Future<ReportCardResult> getReportCard({int? studentId, int? reportCardId});
}

class ReportCardRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ReportCardRemoteDataSource {
  final Dio dio;
  ReportCardRemoteDataSourceImpl({required this.dio});

  String _path({int? studentId, int? reportCardId}) {
    if (studentId != null) {
      // ولي الأمر: reportCardId بآخر المسار
      return '/api/guardian/students/$studentId/report-cards/$reportCardId';
    }
    // الطالب: مع أو بدون فصل محدّد
    // ⚠️ راجع مسار الطالب الحقيقي للفصل المحدّد إذا مختلف
    return reportCardId != null
        ? '/api/student/report-cards/$reportCardId'
        : '/api/student/report-cards';
  }

  @override
  Future<ReportCardResult> getReportCard(
      {int? studentId, int? reportCardId}) async {
    return execute(() async {
      final path = _path(studentId: studentId, reportCardId: reportCardId);
      debugPrint("🚀 [ReportCardRemote] جلب الجلاء | path: $path");

      final response = await dio.get(path);
      debugPrint("✅ [ReportCardRemote] رد الجلاء: ${response.data}");

      final body = (response.data as Map<String, dynamic>?) ?? const {};
      final message = body['message']?.toString() ?? '';
      final data = body['data'];

      // جلاء صالح فقط لو data كانت Map غير فارغة.
      // (status:false، أو data:null، أو data:[] الفاضية → حالة فراغ برسالة)
      final hasCard = data is Map<String, dynamic> && data.isNotEmpty;
      if (!hasCard) {
        return ReportCardResult(
          reportCard: null,
          message: message.isNotEmpty ? message : 'لا يوجد جلاء لعرضه',
        );
      }

      return ReportCardResult(
        reportCard: ReportCardModel.fromJson(data),
        message: message,
      );
    });
  }
}