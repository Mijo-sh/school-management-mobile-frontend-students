import 'package:equatable/equatable.dart';

class ReportCard extends Equatable {
  final int reportCardId;
  final int studentId;
  final String studentName;
  final ReportCardSummary summary;
  final List<SubjectResult> subjects;

  const ReportCard({
    required this.reportCardId,
    required this.studentId,
    required this.studentName,
    required this.summary,
    required this.subjects,
  });

  @override
  List<Object?> get props =>
      [reportCardId, studentId, studentName, summary, subjects];
}

class ReportCardSummary extends Equatable {
  final double totalMarks;
  final double maxTotalMarks;
  final String attendanceStatus;
  final String finalResult;
  final List<String> failureReasons;

  const ReportCardSummary({
    required this.totalMarks,
    required this.maxTotalMarks,
    required this.attendanceStatus,
    required this.finalResult,
    required this.failureReasons,
  });

  bool get isPassed => finalResult.toLowerCase() == 'passed';

  @override
  List<Object?> get props =>
      [totalMarks, maxTotalMarks, attendanceStatus, finalResult, failureReasons];
}

class SubjectResult extends Equatable {
  final String subjectName;
  final bool isFailingSubject; // مادة أساسية (رسوبها يرسّب الطالب)
  final double subjectTotal;
  final double maxMark;
  final double passingMark;
  final String status;
  final List<EvaluationItem> evaluations;

  const SubjectResult({
    required this.subjectName,
    required this.isFailingSubject,
    required this.subjectTotal,
    required this.maxMark,
    required this.passingMark,
    required this.status,
    required this.evaluations,
  });

  bool get isPassed => status.toLowerCase() == 'passed';

  @override
  List<Object?> get props => [
    subjectName,
    isFailingSubject,
    subjectTotal,
    maxMark,
    passingMark,
    status,
    evaluations,
  ];
}

class EvaluationItem extends Equatable {
  final String key; // oral, homework, quiz1...
  final String name; // الاسم العربي
  final double mark;
  final double maxMark;

  const EvaluationItem({
    required this.key,
    required this.name,
    required this.mark,
    required this.maxMark,
  });

  @override
  List<Object?> get props => [key, name, mark, maxMark];
}