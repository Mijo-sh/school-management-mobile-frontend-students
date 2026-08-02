import '../../domain/entities/evaluation_item.dart';
import '../../domain/entities/evaluation_rating.dart';

class EvaluationItemModel extends EvaluationItem {
  const EvaluationItemModel({
    required super.id,
    required super.rating,
    required super.ratingArabic,
    required super.notes,
    required super.createdAt,
    required super.subjectName,
    required super.isRead,
  });

  factory EvaluationItemModel.fromJson(Map<String, dynamic> json) {
    final subjectMap = json['subject'] as Map<String, dynamic>?;
    final subjectName = subjectMap?['name']?.toString() ?? '';

    return EvaluationItemModel(
      id: json['id'] as int,
      rating: EvaluationRating.fromApiValue(json['rating'] as String?),
      ratingArabic: json['rating_arabic']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      subjectName: subjectName,
      // نفس احتياط is_raed/is_read المستخدم بباقي الفيتشرز.
      isRead: (json['is_raed'] ?? json['is_read']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating.name == 'veryGood' ? 'very_good' : rating.name,
      'rating_arabic': ratingArabic,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'subject': {'name': subjectName},
      'is_read': isRead,
    };
  }
}
