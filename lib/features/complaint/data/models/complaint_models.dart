// lib/features/complaint/data/models/complaint_models.dart

import '../../domain/entities/complaint_entities.dart';

// ══════════ options ══════════

class ComplaintCategoryModel extends ComplaintCategory {
  const ComplaintCategoryModel({
    required super.id,
    required super.name,
    required super.types,
  });

  factory ComplaintCategoryModel.fromJson(Map<String, dynamic> json) {
    final typesJson = (json['types'] as List?) ?? const [];
    return ComplaintCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      types: typesJson
          .map((t) => ComplaintTypeModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ComplaintTypeModel extends ComplaintType {
  const ComplaintTypeModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.severity,
  });

  factory ComplaintTypeModel.fromJson(Map<String, dynamic> json) {
    return ComplaintTypeModel(
      id: (json['id'] as num).toInt(),
      categoryId: (json['complaint_category_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
    );
  }
}

// ══════════ show ══════════

class ComplaintModel extends Complaint {
  const ComplaintModel({
    required super.id,
    required super.type,
    required super.categoryName,
    required super.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final typeJson = (json['complaint_type'] as Map<String, dynamic>?) ?? {};
    final categoryJson = (typeJson['category'] as Map<String, dynamic>?) ?? {};
    final studentJson = (json['student'] as Map<String, dynamic>?) ?? {};
    final userJson = (studentJson['user'] as Map<String, dynamic>?) ?? {};

    final first = userJson['first_name']?.toString() ?? '';
    final father = userJson['father_name']?.toString() ?? '';
    final last = userJson['last_name']?.toString() ?? '';
    final fullName = [first, father, last]
        .where((s) => s.isNotEmpty)
        .join(' ');

    return ComplaintModel(
      id: (json['id'] as num).toInt(),
      type: ComplaintTypeBrief(
        id: (typeJson['id'] as num?)?.toInt() ?? 0,
        title: typeJson['title']?.toString() ?? '',
        severity: typeJson['severity']?.toString() ?? '',
      ),
      categoryName: categoryJson['name']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
