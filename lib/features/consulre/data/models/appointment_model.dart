// data/models/appointment_model.dart
import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    super.id,
    required super.appointmentDate,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.student,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: (json['id'] as num?)?.toInt(),
      appointmentDate: json['appointment_date'] as String,
      startTime: _trim(json['start_time'] as String),
      endTime: _trim(json['end_time'] as String),
      status: json['status'] as String,
      student: json['student'] != null
          ? AppointmentStudentModel.fromJson(json['student'])
          : null,
    );
  }

  static String _trim(String t) {
    final parts = t.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return t;
  }
}

class AppointmentStudentModel extends AppointmentStudent {
  const AppointmentStudentModel({
    required super.id,
    required super.name,
    required super.photoUrl,
  });

  factory AppointmentStudentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentStudentModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }
}