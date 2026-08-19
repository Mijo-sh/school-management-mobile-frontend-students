import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/unread_counts_store.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/payment_alert_item.dart';
import '../../domain/use_cases/ get_payment_alerts_usecase.dart';
import '../../domain/use_cases/mark_payment_alert_as_read_usecase.dart';

typedef PaymentAlertsState = FeedState<PaymentAlertItem>;
typedef PaymentAlertsInitial = FeedInitial<PaymentAlertItem>;
typedef PaymentAlertsLoading = FeedLoading<PaymentAlertItem>;
typedef PaymentAlertsLoaded = FeedLoaded<PaymentAlertItem>;
typedef PaymentAlertsError = FeedError<PaymentAlertItem>;

class PaymentAlertsCubit extends FeedCubit<PaymentAlertItem> {
  final GetPaymentAlertsUseCase getPaymentAlertsUseCase;
  final MarkPaymentAlertAsReadUseCase markPaymentAlertAsReadUseCase;

  PaymentAlertsCubit({
    required this.getPaymentAlertsUseCase,
    required this.markPaymentAlertAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<PaymentAlertItem>>> fetchPage({
    required int page,
  }) {
    return getPaymentAlertsUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markPaymentAlertAsReadUseCase(studentId: studentId);
  }

  Future<void> loadAlerts() => load();

  // ⚠️ لازم تضيف clearPaymentAlerts() بالـ UnreadCountsStore (تحت بالملاحظات)
  @override
  void clearBadge() => di<UnreadCountsStore>().clearPaymentAlerts();

  // ⚠️ لازم تضيف NotificationType.payment (تحت بالملاحظات)
  @override
  Set<String> get notificationTypes => {NotificationType.payment};
}