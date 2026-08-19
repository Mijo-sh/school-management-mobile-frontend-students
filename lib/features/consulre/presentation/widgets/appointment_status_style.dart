// presentation/widgets/appointment_status_style.dart
import 'package:flutter/material.dart';

class StatusStyle {
  final String label;
  final Color color;
  const StatusStyle(this.label, this.color);
}

StatusStyle statusStyle(String status) {
  switch (status) {
    case 'pending':
      return const StatusStyle('قيد الانتظار', Colors.orange);
    case 'accepted':
      return const StatusStyle('مقبول', Colors.green);
    case 'completed':
      return const StatusStyle('منتهي', Colors.grey);
    case 'cancelled':
      return const StatusStyle('ملغى', Colors.red);
    case 'rejected':
      return const StatusStyle('مرفوض', Colors.red);
    default:
      return StatusStyle(status, Colors.blueGrey);
  }
}