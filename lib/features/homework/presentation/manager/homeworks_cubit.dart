import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/homework_item.dart';
import '../../domain/use_cases/get_homeworks_usecase.dart';
import '../../domain/use_cases/mark_all_homeworks_as_read_usecase.dart';

typedef HomeworksState = FeedState<HomeworkItem>;
typedef HomeworksInitial = FeedInitial<HomeworkItem>;
typedef HomeworksLoading = FeedLoading<HomeworkItem>;
typedef HomeworksLoaded = FeedLoaded<HomeworkItem>;
typedef HomeworksError = FeedError<HomeworkItem>;

class HomeworksCubit extends FeedCubit<HomeworkItem> {
  final GetHomeworksUseCase getHomeworksUseCase;
  final MarkAllHomeworksAsReadUseCase markHomeworksAsReadUseCase;

  HomeworksCubit({
    required this.getHomeworksUseCase,
    required this.markHomeworksAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<HomeworkItem>>> fetchPage({required int page}) {
    return getHomeworksUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markHomeworksAsReadUseCase(studentId: studentId);
  }

  Future<void> loadHomeworks() => load();
}
