import 'package:equatable/equatable.dart';

class TopStudent extends Equatable {
  final int id;
  final String fullName;
  final String photoUrl;
  final String gradeLevel;
  final String classRoom;
  final String totalMarks;
  final String maxTotalMarks;
  final String percentage;
  final String result;
  final bool isMyChild;
  final bool isMe;

  const TopStudent({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    required this.gradeLevel,
    required this.classRoom,
    required this.totalMarks,
    required this.maxTotalMarks,
    required this.percentage,
    required this.result,
    this.isMyChild = false,
    this.isMe = false,
  });

  // صحيح لو هالكارد يخص المستخدم الحالي (طالب) أو ابنه (ولي أمر)
  bool get isHighlighted => isMe || isMyChild;

  @override
  List<Object?> get props => [
    id,
    fullName,
    photoUrl,
    gradeLevel,
    classRoom,
    totalMarks,
    maxTotalMarks,
    percentage,
    result,
    isMyChild,
    isMe,
  ];
}