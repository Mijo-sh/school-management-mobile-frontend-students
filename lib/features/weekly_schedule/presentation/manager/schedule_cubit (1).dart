import 'package:bloc/bloc.dart';
import 'package:school_management_mobile_frontend_students/features/weekly_schedule/presentation/manager/schedule_state%20(1).dart';

import '../../data/data_sources/local/schedule_local_data_source .dart';
import '../../domain/use_cases/get_weekly_schedule_usecase.dart';


class ScheduleCubit extends Cubit<ScheduleState> {
  final GetWeeklyScheduleUseCase getWeeklyScheduleUseCase;
  final ScheduleLocalDataSource localDataSource;

  ScheduleCubit({
    required this.getWeeklyScheduleUseCase,
    required this.localDataSource,
  }) : super(const ScheduleInitial());

  /// studentId اختياري: الأب يمرّره، الطالب null (الباك يعرفه من التوكن).
  Future<void> fetchWeekly(int? studentId) async {
    emit(const ScheduleLoading());
    final result = await getWeeklyScheduleUseCase(studentId);

    result.fold(
          (failure) async {
        // فشل السيرفر → نحاول الكاش المحلي
        try {
          final cachedSchedule = await localDataSource.getCachedWeekly(studentId);
          emit(ScheduleLoaded(
            cachedSchedule,
            warningMessage:
            'فشل الاتصال بالإنترنت، يتم عرض النسخة المخزنة مؤقتاً.',
          ));
        } catch (_) {
          emit(ScheduleError(failure.message));
        }
      },
          (schedule) => emit(ScheduleLoaded(schedule)),
    );
  }

  void emitError(String message) => emit(ScheduleError(message));
}