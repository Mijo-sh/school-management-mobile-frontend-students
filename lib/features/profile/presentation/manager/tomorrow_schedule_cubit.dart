import 'package:bloc/bloc.dart';

import '../../../weekly_schedule/domain/use_cases/get_tomorrow_schedule_usecase.dart';
import 'tomorrow_schedule_state.dart';

class TomorrowScheduleCubit extends Cubit<TomorrowScheduleState> {
  final GetTomorrowScheduleUseCase getTomorrowScheduleUseCase;

  TomorrowScheduleCubit({required this.getTomorrowScheduleUseCase})
      : super(TomorrowInitial());

  Future<void> fetchTomorrow(int? studentId) async {
    emit(TomorrowLoading());
    final result = await getTomorrowScheduleUseCase(studentId);
    result.fold(
      (failure) => emit(TomorrowError(failure.message)),
      (schedule) {
        // الرد خريطة فيها يوم واحد (بكرا). ناخد أول (وغالبًا الوحيد) مفتاح.
        if (schedule.isEmpty) {
          emit(TomorrowLoaded(dayKey: '', entries: []));
          return;
        }
        final entry = schedule.entries.first;
        emit(TomorrowLoaded(dayKey: entry.key, entries: entry.value));
      },
    );
  }

  void emitError(String message) => emit(TomorrowError(message));
}
