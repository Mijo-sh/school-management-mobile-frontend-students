import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/alert_item.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/use_cases/mark_alert_as_read_usecase.dart';

// أسماء بديلة (typedef) — حتى AlertsPage الحالية تضل شغالة بدون أي
// تعديل عليها (لسا بتستخدم AlertsState/AlertsLoaded/AlertsError...).
typedef AlertsState = FeedState<AlertItem>;
typedef AlertsInitial = FeedInitial<AlertItem>;
typedef AlertsLoading = FeedLoading<AlertItem>;
typedef AlertsLoaded = FeedLoaded<AlertItem>;
typedef AlertsError = FeedError<AlertItem>;

class AlertsCubit extends FeedCubit<AlertItem> {
  final GetAlertsUseCase getAlertsUseCase;
  final MarkAlertAsReadUseCase markAlertAsReadUseCase;

  AlertsCubit({
    required this.getAlertsUseCase,
    required this.markAlertAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<AlertItem>>> fetchPage({required int page}) {
    return getAlertsUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markAlertAsReadUseCase(studentId: studentId);
  }

  /// اسم بديل — AlertsPage الحالية بتنادي loadAlerts() مش load().
  Future<void> loadAlerts() => load();
}
