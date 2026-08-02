import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/evaluation_item.dart';
import '../../domain/use_cases/get_evaluations_usecase.dart';
import '../../domain/use_cases/mark_all_evaluations_as_read_usecase.dart';

// أسماء بديلة — حتى EvaluationsPage تستخدم أسماء واضحة (مطابقة
// لنفس نمط AlertsState/AlertsLoaded... بباقي الفيتشرز).
typedef EvaluationsState = FeedState<EvaluationItem>;
typedef EvaluationsInitial = FeedInitial<EvaluationItem>;
typedef EvaluationsLoading = FeedLoading<EvaluationItem>;
typedef EvaluationsLoaded = FeedLoaded<EvaluationItem>;
typedef EvaluationsError = FeedError<EvaluationItem>;

class EvaluationsCubit extends FeedCubit<EvaluationItem> {
  final GetEvaluationsUseCase getEvaluationsUseCase;
  final MarkAllEvaluationsAsReadUseCase markEvaluationsAsReadUseCase;

  EvaluationsCubit({
    required this.getEvaluationsUseCase,
    required this.markEvaluationsAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<EvaluationItem>>> fetchPage({required int page}) {
    return getEvaluationsUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markEvaluationsAsReadUseCase(studentId: studentId);
  }

  /// اسم بديل — EvaluationsPage بتنادي loadEvaluations() مش load().
  Future<void> loadEvaluations() => load();
}
