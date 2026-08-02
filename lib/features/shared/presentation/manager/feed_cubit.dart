import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/manager/readable_feed_item.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../../core/unread_counts_store.dart';
import '../../domain/entities/paginated.dart';
import 'feed_state.dart';
/// كيوبت عام لأي "قائمة قابلة للقراءة" مع Pagination — تنبيهات،
/// إعلانات، أنشطة، وأي فيتشر مستقبلي مشابه (علامات، تقييمات...).
///
/// كل فيتشر جديد بيرث منها ويعرّف بس دالتين (`fetchPage`, `markAllRead`)
/// — الباقي (تحميل، صفحات، تصفير صامت بالخلفية، الاستماع للإشعارات
/// اللحظية وتحديث القائمة تلقائيًا، تحديث البادج المركزي) موحّد هون
/// مرة وحدة بس.
abstract class FeedCubit<T extends ReadableFeedItem> extends Cubit<FeedState<T>> {
  final int? studentId;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  final List<T> _allItems = [];

  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  FeedCubit({this.studentId}) : super(FeedInitial<T>()) {
    // لو وصل إشعار والمستخدم فاتح هالصفحة بالذات، منعيد جلب القائمة
    // فورًا حتى يبين العنصر الجديد مباشرة.
    _foregroundSub = di<PushNotificationRepository>().onForegroundMessage.listen((_) {
      load();
    });
  }

  // ── الدالتين يلي كل فيتشر لازم يعرّفهم ──────────────────────
  Future<Either<Failure, Paginated<T>>> fetchPage({required int page});
  Future<Either<Failure, Unit>> markAllRead();

  // ── المنطق المشترك (موحّد هون مرة وحدة) ─────────────────────
  Future<void> load() async {
    _currentPage = 1;
    _allItems.clear();
    emit(FeedLoading<T>());

    final result = await fetchPage(page: 1);
    result.fold(
      (failure) => emit(FeedError<T>(failure.message)),
      (paginated) {
        _allItems.addAll(paginated.items);
        final hasMore = paginated.currentPage < paginated.lastPage;
        emit(FeedLoaded<T>(List.from(_allItems), hasMore: hasMore));

        // تأخير مقصود لتجربة مستخدم جميلة (رؤية حالة غير المقروء
        // قبل ما تتحول) قبل التصفير الصامت بالخلفية.
        Future.delayed(const Duration(milliseconds: 900), markAsRead);
      },
    );
  }

  Future<void> loadNextPage() async {
    if (_isFetchingMore || state is! FeedLoaded<T>) return;

    final currentState = state as FeedLoaded<T>;
    if (!currentState.hasMore) return;

    _isFetchingMore = true;
    _currentPage++;

    final result = await fetchPage(page: _currentPage);
    result.fold(
      (failure) {
        _isFetchingMore = false;
        _currentPage--;
      },
      (paginated) {
        _allItems.addAll(paginated.items);
        final hasMore = paginated.currentPage < paginated.lastPage;
        emit(FeedLoaded<T>(List.from(_allItems), hasMore: hasMore));
        _isFetchingMore = false;
      },
    );
  }

  Future<void> markAsRead() async {
    final current = state;
    if (current is! FeedLoaded<T>) return;

    final hasUnread = current.items.any((i) => !i.isRead);
    if (!hasUnread) return;

    final result = await markAllRead();
    result.fold(
      (failure) {
        if (state is FeedLoaded<T>) emit(current); // rollback بصمت
      },
      (_) {
        // نحدّث البادج المركزي فورًا — ما لازم ننتظر أي إشعار جديد.
        di<UnreadCountsStore>().refreshNow();
      },
    );
  }

  @override
  Future<void> close() {
    _foregroundSub?.cancel();
    return super.close();
  }
}
