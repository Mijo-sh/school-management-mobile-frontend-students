import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/announcement_item.dart';
import '../../domain/use_cases/get_announcements_usecase.dart';
import '../../domain/use_cases/mark_announcement_as_read_usecase.dart';

typedef AnnouncementsState = FeedState<AnnouncementItem>;
typedef AnnouncementsInitial = FeedInitial<AnnouncementItem>;
typedef AnnouncementsLoading = FeedLoading<AnnouncementItem>;
typedef AnnouncementsLoaded = FeedLoaded<AnnouncementItem>;
typedef AnnouncementsError = FeedError<AnnouncementItem>;

class AnnouncementsCubit extends FeedCubit<AnnouncementItem> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;
  final MarkAnnouncementAsReadUseCase markAnnouncementsAsReadUseCase;

  AnnouncementsCubit({
    required this.getAnnouncementsUseCase,
    required this.markAnnouncementsAsReadUseCase,
    super.studentId,
  });

  @override
  Future<Either<Failure, Paginated<AnnouncementItem>>> fetchPage({required int page}) {
    return getAnnouncementsUseCase(studentId: studentId, page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markAnnouncementsAsReadUseCase(studentId: studentId);
  }

  Future<void> loadAnnouncements() => load();
}
