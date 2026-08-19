// presentation/bloc/appointment_event.dart
part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class GetMyAppointmentsEvent extends AppointmentEvent {}

class GetAvailableSlotsEvent extends AppointmentEvent {}

class BookAppointmentEvent extends AppointmentEvent {
  final String date;
  final String startTime;
  final String endTime;

  const BookAppointmentEvent({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [date, startTime, endTime];
}

class CancelAppointmentEvent extends AppointmentEvent {
  final int id;
  const CancelAppointmentEvent({required this.id});

  @override
  List<Object> get props => [id];
}