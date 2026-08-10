import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../../../app_intro/data/data_sources/app_session_local_data_source.dart';

class DownloadResult {
  final bool success;
  final String? filePath;
  final String? error;
  const DownloadResult({required this.success, this.filePath, this.error});
}

class MaterialDownloader {
  final AppSessionLocalDataSource sessionLocalDataSource;
  final Dio dio; // 👈 نضيفه عشان ناخد baseUrl

  MaterialDownloader({
    required this.sessionLocalDataSource,
    required this.dio,
  });

  Future<DownloadResult> download({
    required int materialId,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final session = await sessionLocalDataSource.getCachedSession();
      final token = session?.token;
      if (token == null) {
        return const DownloadResult(success: false, error: 'انتهت صلاحية الجلسة');
      }

      // مجلد Downloads العام
      final downloadsPath = '/storage/emulated/0/Download';
      final safeName = fileName.replaceAll('/', '-');

      // 💡 فحص وجود الملف وإضافة رقم تسلسلي إذا كان موجوداً لتجنب الكتابة فوقه
      String filePath = '$downloadsPath/$safeName';
      int counter = 1;

      File file = File(filePath);
      while (file.existsSync()) {
        final lastDot = safeName.lastIndexOf('.');
        String nameWithoutExtension = lastDot != -1 ? safeName.substring(0, lastDot) : safeName;
        String extension = lastDot != -1 ? safeName.substring(lastDot) : '';

        filePath = '$downloadsPath/$nameWithoutExtension ($counter)$extension';
        file = File(filePath);
        counter++;
      }

      await dio.download(
        '/api/user/helper/materials/download/$materialId', // نسبي، dio بيضيف baseUrl
        filePath,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total * 100);
        },
      );

      return DownloadResult(success: true, filePath: filePath);
    } on DioException catch (e) {
      print('🔴 خطأ تنزيل: ${e.response?.statusCode}');
      return const DownloadResult(success: false, error: 'تعذّر التنزيل');
    } catch (e) {
      print('🔴 خطأ: $e');
      return const DownloadResult(success: false, error: 'حدث خطأ أثناء التنزيل');
    }
  }
}