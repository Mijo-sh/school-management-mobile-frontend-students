// lib/features/complaint/domain/entities/complaint_entities.dart

// ══════════ خيارات الشكوى (options) ══════════

/// تصنيف عام يحتوي أنواع شكاوى.
class ComplaintCategory {
  final int id;
  final String name;
  final List<ComplaintType> types;

  const ComplaintCategory({
    required this.id,
    required this.name,
    required this.types,
  });
}

/// نوع شكوى محدّد ضمن تصنيف.
class ComplaintType {
  final int id;
  final int categoryId;
  final String title;
  final String severity; // high / medium / low

  const ComplaintType({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.severity,
  });
}

// ══════════ شكوى معروضة (show) ══════════

/// بند شكوى مقدَّمة (كما تُعرض بالقائمة).
class Complaint {
  final int id;
  final ComplaintTypeBrief type;
  final String categoryName;
  final DateTime? createdAt;

  const Complaint({
    required this.id,
    required this.type,
    required this.categoryName,
    required this.createdAt,
  });
}

/// نوع الشكوى داخل بند معروض (مختصر).
class ComplaintTypeBrief {
  final int id;
  final String title;
  final String severity;

  const ComplaintTypeBrief({
    required this.id,
    required this.title,
    required this.severity,
  });
}



// ══════════ إنشاء شكوى (create) ══════════

/// حمولة إنشاء شكوى جديدة.
class ComplaintToCreate {
  final int studentId;
  final int complaintTypeId;

  const ComplaintToCreate({
    required this.studentId,
    required this.complaintTypeId,
  });
}
