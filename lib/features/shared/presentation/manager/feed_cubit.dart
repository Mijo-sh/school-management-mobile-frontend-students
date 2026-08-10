import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/manager/readable_feed_item.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../domain/entities/paginated.dart';
import 'feed_state.dart';

/// كيوبت عام لأي "قائمة قابلة للقراءة" مع Pagination — تنبيهات،
/// إعلانات، أنشطة، تقييمات، وظائف، علامات.
///
/// كل فيتشر بيرث منها ويعرّف:
///   - fetchPage / markAllRead : جلب صفحة / تصفير بالسيرفر
///   - notificationTypes       : أنواع الإشعارات اللي تخصّه (للفلترة)
///   - clearBadge              : تصفير عدّاده المركزي محليًا
///
/// الباقي (تحميل، صفحات، تصفير صامت، الفلترة الذكية للإشعارات) موحّد
/// هون مرة وحدة.
abstract class FeedCubit<T extends ReadableFeedItem> extends Cubit<FeedState<T>> {
  final int? studentId;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  final List<T> _allItems = [];

  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  FeedCubit({this.studentId}) : super(FeedInitial<T>()) {
    // فلترة ذكية: منعيد تحميل القائمة فقط لو الإشعار يخص هالفيتشر.
    // (قبلها كان أي إشعار يعيد تحميل كل القوائم المفتوحة — هدر.)
    _foregroundSub =
        di<PushNotificationRepository>().onForegroundMessage.listen((data) {
          final type = resolveNotificationType(data);
          if (type != null && notificationTypes.contains(type)) {
            load();
          }
        });
  }

  // ── يعرّفهم كل فيتشر ─────────────────────────────────────────
  Future<Either<Failure, Paginated<T>>> fetchPage({required int page});
  Future<Either<Failure, Unit>> markAllRead();

  /// أنواع الإشعارات اللي تخص هالفيتشر (للفلترة).
  Set<String> get notificationTypes;

  /// تصفير عدّاد هالفيتشر المركزي محليًا (بدون نداء).
  void clearBadge();

  // ── المنطق المشترك ──────────────────────────────────────────
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

        // تأخير مقصود لتجربة جميلة (رؤية غير المقروء قبل ما يتحوّل)
        // قبل التصفير الصامت بالخلفية.
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
        // تصفير العدّاد المركزي محليًا فورًا (بدون جلب الكل).
        clearBadge();
      },
    );
  }

  @override
  Future<void> close() {
    _foregroundSub?.cancel();
    return super.close();
  }
}