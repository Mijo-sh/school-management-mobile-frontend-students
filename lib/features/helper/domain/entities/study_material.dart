import 'package:equatable/equatable.dart';
import '../../../shared/presentation/manager/readable_feed_item.dart';

/// نوع المادة المساعدة: ملف قابل للتنزيل، أو رابط خارجي.
enum MaterialType { file, link, unknown }

class StudyMaterial extends Equatable implements ReadableFeedItem {
  final int id;
  final String title;
  final String? description;
  final MaterialType type;
  final String? linkUrl;        // للنوع link
  final String? filePath;       // للنوع file (مسار السيرفر)
  final String? fileExtension;  // pdf, docx...
  final int? fileSizeKb;
  @override
  final bool isRead;
  final DateTime createdAt;

  const StudyMaterial({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.linkUrl,
    this.filePath,
    this.fileExtension,
    this.fileSizeKb,
    required this.isRead,
    required this.createdAt,
  });

  bool get isFile => type == MaterialType.file;
  bool get isLink => type == MaterialType.link;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        linkUrl,
        filePath,
        fileExtension,
        fileSizeKb,
        isRead,
        createdAt,
      ];
}
