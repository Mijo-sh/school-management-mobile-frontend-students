import 'package:bloc/bloc.dart';
import 'package:school_management_mobile_frontend_students/features/weekly_schedule/presentation/manager/schedule_state%20(1).dart';

import '../../domain/use_cases/get_weekly_schedule_usecase.dart';
// استدعاء الكاش داتا سورس أو الـ use case الخاص بك هنا
import '../../data/data_sources/local/schedule_local_data_source .dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetWeeklyScheduleUseCase getWeeklyScheduleUseCase;
  final ScheduleLocalDataSource localDataSource; // 👈 إضافة الكاش هنا

  ScheduleCubit({
    required this.getWeeklyScheduleUseCase,
    required this.localDataSource,
  }) : super(const ScheduleInitial());

  Future<void> fetchWeekly(int studentId) async {
    emit(const ScheduleLoading());
    final result = await getWeeklyScheduleUseCase(studentId);

    result.fold(
          (failure) async {
        // إذا فشل الاتصال بالسيرفر، نحاول جلب البيانات المخزنة (الكاش) محلياً
        try {
          final cachedSchedule = await localDataSource.getCachedWeekly(studentId);
          // إذا نجح في جلب الكاش، نعرض الجدول مع رسالة تحذيرية أن البيانات قديمة
          emit(ScheduleLoaded(
            cachedSchedule,
            warningMessage: 'فشل الاتصال بالإنترنت، يتم عرض النسخة المخزنة مؤقتاً.',
          ));
        } catch (_) {
          // إذا لم يوجد كاش أيضاً، نظهر خطأ الفشل الحقيقي
          emit(ScheduleError(failure.message));
        }
      },
          (schedule) {
        // إذا نجح الاتصال بالسيرفر وجلب البيانات الحديثة
        emit(ScheduleLoaded(schedule));
      },
    );
  }

  void emitError(String message) => emit(ScheduleError(message));
}