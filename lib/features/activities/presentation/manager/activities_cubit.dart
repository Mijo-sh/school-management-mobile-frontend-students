import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/use_cases/get_activities_usecase.dart';
import '../../domain/use_cases/mark_all_activities_as_read_usecase.dart';

typedef ActivitiesState = FeedState<ActivityItem>;
typedef ActivitiesInitial = FeedInitial<ActivityItem>;
typedef ActivitiesLoading = FeedLoading<ActivityItem>;
typedef ActivitiesLoaded = FeedLoaded<ActivityItem>;
typedef ActivitiesError = FeedError<ActivityItem>;

class ActivitiesCubit extends FeedCubit<ActivityItem> {
  final GetActivitiesUseCase getActivitiesUseCase;
  final MarkAllActivitiesAsReadUseCase markActivitiesAsReadUseCase;

  ActivitiesCubit({
    required this.getActivitiesUseCase,
    required this.markActivitiesAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<ActivityItem>>> fetchPage({required int page}) {
    return getActivitiesUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markActivitiesAsReadUseCase(studentId: studentId);
  }

  Future<void> loadActivities() => load();
}
