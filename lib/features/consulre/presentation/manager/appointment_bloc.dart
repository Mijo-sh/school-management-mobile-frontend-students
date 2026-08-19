// presentation/bloc/appointment_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/available_slot.dart';
import '../../domain/use_cases/book_appointment_use_case.dart';
import '../../domain/use_cases/cancel_appointment_use_case.dart';
import '../../domain/use_cases/get_available_slots_use_case.dart';
import '../../domain/use_cases/get_my_appointments_use_case.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetAvailableSlotsUseCase getAvailableSlots;
  final GetMyAppointmentsUseCase getMyAppointments;
  final BookAppointmentUseCase bookAppointment;
  final CancelAppointmentUseCase cancelAppointment;

  AppointmentBloc({
    required this.getAvailableSlots,
    required this.getMyAppointments,
    required this.bookAppointment,
    required this.cancelAppointment,
  }) : super(const AppointmentState()) {
    on<GetMyAppointmentsEvent>(_onGetMy);
    on<GetAvailableSlotsEvent>(_onGetSlots);
    on<BookAppointmentEvent>(_onBook);
    on<CancelAppointmentEvent>(_onCancel);
  }

  // هل عنده موعد فعّال (pending أو accepted)؟
  bool _hasActiveAppointment(List<Appointment> list) {
    return list.any((a) => a.status == 'pending' || a.status == 'accepted');
  }

  Future<void> _onGetMy(
      GetMyAppointmentsEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(state.copyWith(status: AppointmentStatus.loading, clearMessage: true));
    final result = await getMyAppointments();
    result.fold(
          (failure) => emit(state.copyWith(
        status: AppointmentStatus.failure,
        message: failure.message,
      )),
          (list) => emit(state.copyWith(
        status: AppointmentStatus.success,
        appointments: list,
        hasActive: _hasActiveAppointment(list),
      )),
    );
  }

  Future<void> _onGetSlots(
      GetAvailableSlotsEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(state.copyWith(
        slotsStatus: SlotsStatus.loading, clearMessage: true));
    final result = await getAvailableSlots();
    result.fold(
          (failure) => emit(state.copyWith(
        slotsStatus: SlotsStatus.failure,
        message: failure.message,
      )),
          (slots) => emit(state.copyWith(
        slotsStatus: SlotsStatus.success,
        slots: slots,
      )),
    );
  }

  Future<void> _onBook(
      BookAppointmentEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(state.copyWith(status: AppointmentStatus.booking, clearMessage: true));
    final result = await bookAppointment(
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
    );
    result.fold(
          (failure) => emit(state.copyWith(
        status: AppointmentStatus.failure,
        message: failure.message,
      )),
          (_) {
        emit(state.copyWith(
          status: AppointmentStatus.booked,
          message: "تم إرسال طلب الحجز بنجاح",
        ));
        add(GetMyAppointmentsEvent());
      },
    );
  }

  Future<void> _onCancel(
      CancelAppointmentEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(state.copyWith(status: AppointmentStatus.cancelling, clearMessage: true));
    final result = await cancelAppointment(id: event.id);
    result.fold(
          (failure) => emit(state.copyWith(
        status: AppointmentStatus.failure,
        message: failure.message,
      )),
          (_) {
        emit(state.copyWith(
          status: AppointmentStatus.cancelled,
          message: "تم إلغاء الموعد بنجاح",
        ));
        add(GetMyAppointmentsEvent());
      },
    );
  }
}