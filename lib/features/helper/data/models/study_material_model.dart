import '../../domain/entities/study_material.dart';

class StudyMaterialModel extends StudyMaterial {
  const StudyMaterialModel({
    required super.id,
    required super.title,
    super.description,
    required super.type,
    super.linkUrl,
    super.filePath,
    super.fileExtension,
    super.fileSizeKb,
    required super.isRead,
    required super.createdAt,
  });

  factory StudyMaterialModel.fromJson(Map<String, dynamic> json) {
    return StudyMaterialModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: _parseType(json['type'] as String?),
      linkUrl: json['link_url'] as String?,
      filePath: json['file_path'] as String?,
      fileExtension: json['file_extension'] as String?,
      fileSizeKb: (json['file_size_kb'] as num?)?.toInt(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static MaterialType _parseType(String? raw) {
    switch (raw) {
      case 'file':
        return MaterialType.file;
      case 'link':
        return MaterialType.link;
      default:
        return MaterialType.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type == MaterialType.file
          ? 'file'
          : type == MaterialType.link
              ? 'link'
              : 'unknown',
      'link_url': linkUrl,
      'file_path': filePath,
      'file_extension': fileExtension,
      'file_size_kb': fileSizeKb,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
