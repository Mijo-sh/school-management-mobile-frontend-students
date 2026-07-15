import 'package:equatable/equatable.dart';

class ChildCard extends Equatable {
  final int id;
  final String firstName;
  final String fatherName;
  final String lastName;
  final String? studentPhotoUrl;
  final String gradeName;
  final String classNumber;
  final String gender;


  const ChildCard({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    this.studentPhotoUrl,
    required this.gradeName,
    required this.classNumber,
    required this.gender,
  });

  String get fullName => '$firstName $fatherName $lastName';

  @override
  List<Object?> get props => [id, firstName, fatherName, lastName];
}