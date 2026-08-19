// domain/entities/available_slot.dart
import 'package:equatable/equatable.dart';

class AvailableSlot extends Equatable {
  final String date; // "2026-08-19"
  final String startTime; // "08:00"
  final String endTime; // "08:30"
  final String status; // "available"

  const AvailableSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  @override
  List<Object?> get props => [date, startTime, endTime, status];
}