import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/use_cases/get_activities_usecase.dart';
import '../../domain/use_cases/mark_all_activities_as_read_usecase.dart';

part 'activities_state.dart';

class ActivitiesCubit extends Cubit<ActivitiesState> {
  final GetActivitiesUseCase getActivitiesUseCase;
  final MarkAllActivitiesAsReadUseCase markActivitiesAsReadUseCase;
  final int? studentId;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  final List<ActivityItem> _allActivities = [];

  ActivitiesCubit({
    required this.getActivitiesUseCase,
    required this.markActivitiesAsReadUseCase,
    this.studentId,
  }) : super(const ActivitiesInitial());

  Future<void> loadActivities() async {
    _currentPage = 1;
    _allActivities.clear();
    emit(const ActivitiesLoading());

    final result = await getActivitiesUseCase(studentId: studentId, page: 1);
    result.fold(
          (failure) => emit(ActivitiesError(failure.message)),
          (paginatedData) {
        // التحويل الآمن لمنع خطأ الـ dynamic list 👇
        final List<ActivityItem> itemsList = List<ActivityItem>.from(paginatedData.items);
        _allActivities.addAll(itemsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(ActivitiesLoaded(List.from(_allActivities), hasMore: hasMore));

        // تأخير بسيط قبل القراءة لمشاهدة الحالة غير المقروءة
        Future.delayed(const Duration(milliseconds: 900), markAsRead);
      },
    );
  }

  Future<void> loadNextPage() async {
    if (_isFetchingMore || state is! ActivitiesLoaded) return;

    final currentState = state as ActivitiesLoaded;
    if (!currentState.hasMore) return;

    _isFetchingMore = true;
    _currentPage++;

    final result = await getActivitiesUseCase(studentId: studentId, page: _currentPage);
    result.fold(
          (failure) {
        _isFetchingMore = false;
        _currentPage--;
      },
          (paginatedData) {
        final List<ActivityItem> itemsList = List<ActivityItem>.from(paginatedData.items);
        _allActivities.addAll(itemsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(ActivitiesLoaded(List.from(_allActivities), hasMore: hasMore));
        _isFetchingMore = false;
      },
    );
  }

  Future<void> markAsRead() async {
    final current = state;
    if (current is! ActivitiesLoaded) return;

    final hasUnread = current.activities.any((a) => !a.isRead);
    if (!hasUnread) return;

    final result = await markActivitiesAsReadUseCase(studentId: studentId);
    result.fold(
          (failure) {
        if (state is ActivitiesLoaded) emit(current); // rollback
      },
          (_) {
        for (var i = 0; i < _allActivities.length; i++) {
          _allActivities[i] = _allActivities[i];
        }
      },
    );
  }
}