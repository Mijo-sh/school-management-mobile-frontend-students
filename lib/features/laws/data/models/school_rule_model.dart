import '../../domain/entities/school_rule.dart';

class SchoolRuleModel extends SchoolRule {
  const SchoolRuleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });

  factory SchoolRuleModel.fromJson(Map<String, dynamic> json) {
    return SchoolRuleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
    };
  }
}