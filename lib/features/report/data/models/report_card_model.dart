import '../../domain/entities/report_card.dart';

class ReportCardModel extends ReportCard {
  const ReportCardModel({
    required super.reportCardId,
    required super.studentId,
    required super.studentName,
    required super.summary,
    required super.subjects,
  });

  factory ReportCardModel.fromJson(Map<String, dynamic> json) {
    return ReportCardModel(
      reportCardId: _toInt(json['report_card_id']),
      studentId: _toInt(json['student_id']),
      studentName: json['student_name'] as String? ?? '',
      summary: ReportCardSummaryModel.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      subjects: ((json['subjects'] as List<dynamic>?) ?? const [])
          .map((e) => SubjectResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_card_id': reportCardId,
      'student_id': studentId,
      'student_name': studentName,
      'summary': (summary as ReportCardSummaryModel).toJson(),
      'subjects':
      subjects.map((s) => (s as SubjectResultModel).toJson()).toList(),
    };
  }
}

class ReportCardSummaryModel extends ReportCardSummary {
  const ReportCardSummaryModel({
    required super.totalMarks,
    required super.maxTotalMarks,
    required super.attendanceStatus,
    required super.finalResult,
    required super.failureReasons,
  });

  factory ReportCardSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportCardSummaryModel(
      totalMarks: _toDouble(json['total_marks']),
      maxTotalMarks: _toDouble(json['max_total_marks']),
      attendanceStatus: json['attendance_status'] as String? ?? '',
      finalResult: json['final_result'] as String? ?? '',
      failureReasons: ((json['failure_reasons'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_marks': totalMarks,
      'max_total_marks': maxTotalMarks,
      'attendance_status': attendanceStatus,
      'final_result': finalResult,
      'failure_reasons': failureReasons,
    };
  }
}

class SubjectResultModel extends SubjectResult {
  const SubjectResultModel({
    required super.subjectName,
    required super.isFailingSubject,
    required super.subjectTotal,
    required super.maxMark,
    required super.passingMark,
    required super.status,
    required super.evaluations,
  });

  factory SubjectResultModel.fromJson(Map<String, dynamic> json) {
    return SubjectResultModel(
      subjectName: json['subject_name'] as String? ?? '',
      isFailingSubject: json['is_failing_subject'] as bool? ?? false,
      subjectTotal: _toDouble(json['subject_total']),
      maxMark: _toDouble(json['max_mark']),
      passingMark: _toDouble(json['passing_mark']),
      status: json['status'] as String? ?? '',
      evaluations: _parseEvaluations(json['evaluations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_name': subjectName,
      'is_failing_subject': isFailingSubject,
      'subject_total': subjectTotal,
      'max_mark': maxMark,
      'passing_mark': passingMark,
      'status': status,
      // نخزّنها دائماً Map حتى تتناسق مع fromJson وقت قراءتها من الكاش
      'evaluations': {
        for (final e in evaluations)
          e.key: (e as EvaluationItemModel).toJson(),
      },
    };
  }

  // ⭐️ النقطة الحرجة: object لما في علامات، و [] فاضية لما ما في.
  static List<EvaluationItemModel> _parseEvaluations(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw.entries.map((entry) {
        final value = (entry.value as Map<String, dynamic>?) ?? const {};
        return EvaluationItemModel(
          key: entry.key,
          name: value['name'] as String? ?? '',
          mark: _toDouble(value['mark']),
          maxMark: _toDouble(value['max_mark']),
        );
      }).toList();
    }
    // List (فاضية) أو null → ما في تقييمات
    return const [];
  }
}

class EvaluationItemModel extends EvaluationItem {
  const EvaluationItemModel({
    required super.key,
    required super.name,
    required super.mark,
    required super.maxMark,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'mark': mark, 'max_mark': maxMark};
  }
}

// ---- Helpers لتفادي اختلاف نوع الأرقام (String / num) ----
double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}