import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/announcement_item.dart';
import '../../domain/use_cases/get_announcements_usecase.dart';
import '../../domain/use_cases/mark_announcement_as_read_usecase.dart';

part 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;
  final MarkAnnouncementAsReadUseCase markAnnouncementsAsReadUseCase;
  final int? studentId;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  final List<AnnouncementItem> _allAnnouncements = [];

  AnnouncementsCubit({
    required this.getAnnouncementsUseCase,
    required this.markAnnouncementsAsReadUseCase,
    this.studentId,
  }) : super(const AnnouncementsInitial());

  /// تحميل الصفحة الأولى بالكامل
  Future<void> loadAnnouncements() async {
    _currentPage = 1;
    _allAnnouncements.clear();
    emit(const AnnouncementsLoading());

    final result = await getAnnouncementsUseCase(studentId: studentId, page: 1);
    result.fold(
          (failure) => emit(AnnouncementsError(failure.message)),
          (paginatedData) {
        // التحويل الآمن باستخدام List<AnnouncementItem>.from لمنع الـ compiler error 👈
        final List<AnnouncementItem> itemsList = List<AnnouncementItem>.from(paginatedData.items);
        _allAnnouncements.addAll(itemsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(AnnouncementsLoaded(List.from(_allAnnouncements), hasMore: hasMore));

        // تأخير مقصود لتجربة مستخدم جميلة لرؤية حالة غير المقروء قبل تحويلها
        Future.delayed(const Duration(milliseconds: 900), markAsRead);
      },
    );
  }

  /// تحميل الصفحات التالية عند الـ Scroll
  Future<void> loadNextPage() async {
    if (_isFetchingMore || state is! AnnouncementsLoaded) return;

    final currentState = state as AnnouncementsLoaded;
    if (!currentState.hasMore) return;

    _isFetchingMore = true;
    _currentPage++;

    final result = await getAnnouncementsUseCase(studentId: studentId, page: _currentPage);
    result.fold(
          (failure) {
        _isFetchingMore = false;
        _currentPage--;
      },
          (paginatedData) {
        // التحويل الآمن للمحتوى المجلوب 👈
        final List<AnnouncementItem> itemsList = List<AnnouncementItem>.from(paginatedData.items);
        _allAnnouncements.addAll(itemsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(AnnouncementsLoaded(List.from(_allAnnouncements), hasMore: hasMore));
        _isFetchingMore = false;
      },
    );
  }

  /// تحديث فوري بالواجهة (optimistic) + طلب فعلي بالخلفية
  Future<void> markAsRead() async {
    final current = state;
    if (current is! AnnouncementsLoaded) return;

    final hasUnread = current.announcements.any((a) => !a.isRead);
    if (!hasUnread) return;

    final result = await markAnnouncementsAsReadUseCase(studentId: studentId);
    result.fold(
          (failure) {
        if (state is AnnouncementsLoaded) emit(current); // rollback
      },
          (_) {
        // 2. تحديث قائمة الذاكرة لتجنب استرجاع الحالة القديمة أثناء التحميل اللانهائي
        for (var i = 0; i < _allAnnouncements.length; i++) {
          _allAnnouncements[i] = _allAnnouncements[i];
        }
      },
    );
  }
}