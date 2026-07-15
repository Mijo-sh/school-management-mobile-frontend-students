import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/activity_item.dart';
import '../../domain/use_cases/get_activities_usecase.dart';
import '../../domain/use_cases/mark_all_activities_as_read_usecase.dart';

part 'activities_state.dart';

class ActivitiesCubit extends Cubit<ActivitiesState> {
  final GetActivitiesUseCase getActivitiesUseCase;
  final MarkAllActivitiesAsReadUseCase markAllAsReadUseCase;
  final int? studentId;

  ActivitiesCubit({
    required this.getActivitiesUseCase,
    required this.markAllAsReadUseCase,
    this.studentId,
  }) : super(const ActivitiesInitial());

  Future<void> loadActivities() async {
    emit(const ActivitiesLoading());
    final result = await getActivitiesUseCase(studentId: studentId);
    result.fold(
      (failure) => emit(ActivitiesError(failure.message)),
      (activities) {
        // نعرض البيانات متل ما جاءت — بدون أي تحديث محلي لحالة القراءة.
        emit(ActivitiesLoaded(activities));
        _markAllAsReadSilently();
      },
    );
  }

  /// طلب "تصفير الكل" بالخلفية فقط — بدون أي تأثير على الشاشة الحالية.
  /// المرة الجاية يلي تنفتح فيها الصفحة، البيانات الجاية من السيرفر
  /// هيك بتكون أصلًا "مقروءة".
  Future<void> _markAllAsReadSilently() async {
    final current = state;
    if (current is! ActivitiesLoaded) return;

    final hasUnread = current.activities.any((a) => !a.isRead);
    if (!hasUnread) return;

    await markAllAsReadUseCase(studentId: studentId);
  }
}
