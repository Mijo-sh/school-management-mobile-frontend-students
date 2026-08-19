import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/unread_counts_store.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/grade_item.dart';
import '../../domain/use_cases/get_grades_usecase.dart';
import '../../domain/use_cases/mark_all_grades_as_read_usecase.dart';

typedef GradesState = FeedState<GradeItem>;
typedef GradesInitial = FeedInitial<GradeItem>;
typedef GradesLoading = FeedLoading<GradeItem>;
typedef GradesLoaded = FeedLoaded<GradeItem>;
typedef GradesError = FeedError<GradeItem>;

class GradesCubit extends FeedCubit<GradeItem> {
  final GetGradesUseCase getGradesUseCase;
  final MarkAllGradesAsReadUseCase markGradesAsReadUseCase;

  GradesCubit({
    required this.getGradesUseCase,
    required this.markGradesAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<GradeItem>>> fetchPage({required int page}) {
    return getGradesUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markGradesAsReadUseCase(studentId: studentId);
  }

  Future<void> loadGrades() => load();
  @override
  void clearBadge() => di<UnreadCountsStore>().clearGrades();

  @override
  Set<String> get notificationTypes => {NotificationType.newMark};


}