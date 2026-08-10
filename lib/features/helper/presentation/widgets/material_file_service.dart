import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app_intro/data/data_sources/app_session_local_data_source.dart';

/// نتيجة عملية (فتح أو تنزيل).
class FileActionResult {
  final bool success;
  final String? error;
  const FileActionResult({required this.success, this.error});

  factory FileActionResult.ok() => const FileActionResult(success: true);
  factory FileActionResult.fail(String msg) =>
      FileActionResult(success: false, error: msg);
}

/// مسؤول عن "فتح" ملف المادة: ينزّله مؤقتًا لمجلد التطبيق ثم يفتحه
/// بالتطبيق الخارجي المناسب (Word / PowerPoint / PDF ...).
///
/// يستخدم dio بمسار نسبي — فبياخد baseUrl والتوكن تلقائيًا زي باقي
/// الطلبات. منفصل عن التنزيل الدائم لـ Downloads (MaterialDownloader).
class MaterialFileService {
  final Dio dio;
  final AppSessionLocalDataSource sessionLocalDataSource;

  MaterialFileService({
    required this.dio,
    required this.sessionLocalDataSource,
  });

  /// ينزّل الملف لمجلد التطبيق المؤقت ويفتحه.
  /// [materialId] معرّف المادة (يُبنى منه المسار).
  /// [fileName] اسم الملف مع الامتداد (مثلاً "history.pdf").
  Future<FileActionResult> openFile({
    required int materialId,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final session = await sessionLocalDataSource.getCachedSession();
      final token = session?.token;
      if (token == null) {
        return FileActionResult.fail('انتهت صلاحية الجلسة، سجّل دخول من جديد');
      }

      // مجلد مؤقت خاص بالتطبيق (ما يحتاج صلاحيات)
      final dir = await getTemporaryDirectory();
      final safeName = fileName.replaceAll('/', '-');
      final filePath = '${dir.path}/$safeName';

      // ننزّل الملف — مسار نسبي، dio بيضيف baseUrl تلقائيًا
      await dio.download(
        '/api/user/helper/materials/download/$materialId',
        filePath,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total * 100);
          }
        },
      );

      // نتأكد إنه انحفظ
      if (!await File(filePath).exists()) {
        return FileActionResult.fail('تعذّر تحميل الملف');
      }

      // نفتحه بالتطبيق الخارجي المناسب
      final result = await OpenFilex.open(filePath);
      if (result.type == ResultType.done) {
        return FileActionResult.ok();
      }
      return FileActionResult.fail('لا يوجد تطبيق لفتح هذا الملف');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return FileActionResult.fail('الملف غير موجود');
      }
      return FileActionResult.fail('تعذّر فتح الملف، تحقق من الاتصال');
    } catch (_) {
      return FileActionResult.fail('حدث خطأ أثناء فتح الملف');
    }
  }
}