// domain/entities/appointment.dart
import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final int? id;
  final String appointmentDate; // "2026-08-19"
  final String startTime; // "08:00"
  final String endTime; // "08:30"
  final String status; // "pending", ...
  final AppointmentStudent? student;

  const Appointment({
    this.id,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.student,
  });

  @override
  List<Object?> get props =>
      [id, appointmentDate, startTime, endTime, status, student];
}

class AppointmentStudent extends Equatable {
  final int id;
  final String name;
  final String photoUrl;

  const AppointmentStudent({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, photoUrl];
}