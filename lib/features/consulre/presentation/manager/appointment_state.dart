// presentation/bloc/appointment_state.dart
part of 'appointment_bloc.dart';

enum AppointmentStatus {
  initial,
  loading,
  success,
  failure,
  booking,
  booked,
  cancelling,
  cancelled,
}

enum SlotsStatus { initial, loading, success, failure }

class AppointmentState extends Equatable {
  final List<Appointment> appointments;
  final List<AvailableSlot> slots;
  final bool hasActive;
  final AppointmentStatus status;
  final SlotsStatus slotsStatus;
  final String? message;

  const AppointmentState({
    this.appointments = const [],
    this.slots = const [],
    this.hasActive = false,
    this.status = AppointmentStatus.initial,
    this.slotsStatus = SlotsStatus.initial,
    this.message,
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    List<AvailableSlot>? slots,
    bool? hasActive,
    AppointmentStatus? status,
    SlotsStatus? slotsStatus,
    String? message,
    bool clearMessage = false,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      slots: slots ?? this.slots,
      hasActive: hasActive ?? this.hasActive,
      status: status ?? this.status,
      slotsStatus: slotsStatus ?? this.slotsStatus,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [appointments, slots, hasActive, status, slotsStatus, message];
}