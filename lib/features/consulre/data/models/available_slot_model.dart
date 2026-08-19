// data/models/available_slot_model.dart
import '../../domain/entities/available_slot.dart';

class AvailableSlotModel extends AvailableSlot {
  const AvailableSlotModel({
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      date: json['date'] as String,
      startTime: _trim(json['start_time'] as String),
      endTime: _trim(json['end_time'] as String),
      status: json['status'] as String,
    );
  }

  static String _trim(String t) {
    final parts = t.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return t;
  }
}