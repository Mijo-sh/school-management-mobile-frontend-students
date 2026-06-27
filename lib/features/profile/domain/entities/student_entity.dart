import 'package:equatable/equatable.dart';

class AcademicInfo extends Equatable {
  final String gradeName;
  final String semesterName;
  final String classNumber;

  const AcademicInfo({
    required this.gradeName,
    required this.semesterName,
    required this.classNumber,
  });

  @override
  List<Object?> get props => [gradeName, semesterName, classNumber];
}