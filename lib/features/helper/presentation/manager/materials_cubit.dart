import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/unread_counts_store.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../../shared/presentation/manager/feed_cubit.dart';
import '../../../shared/presentation/manager/feed_state.dart';
import '../../domain/entities/study_material.dart';
import '../../domain/use_cases/get_materials_usecase.dart';
import '../../domain/use_cases/mark_all_materials_as_read_usecase.dart';

typedef MaterialsState = FeedState<StudyMaterial>;
typedef MaterialsInitial = FeedInitial<StudyMaterial>;
typedef MaterialsLoading = FeedLoading<StudyMaterial>;
typedef MaterialsLoaded = FeedLoaded<StudyMaterial>;
typedef MaterialsError = FeedError<StudyMaterial>;

class MaterialsCubit extends FeedCubit<StudyMaterial> {
  final GetMaterialsUseCase getMaterialsUseCase;
  final MarkAllMaterialsAsReadUseCase markMaterialsAsReadUseCase;

  MaterialsCubit({
    required this.getMaterialsUseCase,
    required this.markMaterialsAsReadUseCase,
  });

  @override
  Future<Either<Failure, Paginated<StudyMaterial>>> fetchPage({required int page}) {
    return getMaterialsUseCase(page: page);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() {
    return markMaterialsAsReadUseCase();
  }

  @override
  Set<String> get notificationTypes => {NotificationType.newStudyMaterial};

  @override
  void clearBadge() => di<UnreadCountsStore>().clearMaterials();

  Future<void> loadMaterials() => load();
}
