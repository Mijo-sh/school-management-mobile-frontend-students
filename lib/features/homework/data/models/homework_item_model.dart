import '../../domain/entities/homework_item.dart';

class HomeworkItemModel extends HomeworkItem {
  const HomeworkItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.createdAt,
    required super.subjectName,
    required super.gradeLevelName,
    required super.isRead,
  });

  factory HomeworkItemModel.fromJson(Map<String, dynamic> json) {

    return HomeworkItemModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      // due_date "2026-07-28" — تاريخ بدون وقت، DateTime.parse بتقبلها.
      dueDate: DateTime.tryParse(json['due_date'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      subjectName: json['subject_name']?.toString() ?? '',
      gradeLevelName: json['grade_level_name']?.toString() ?? '',
      isRead: (json['is_raed'] ?? json['is_read']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date':
          '${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
      'created_at': createdAt.toIso8601String(),
      'subject_name': subjectName,
      'grade_level_name': gradeLevelName,
      'is_read': isRead,
    };
  }
}
