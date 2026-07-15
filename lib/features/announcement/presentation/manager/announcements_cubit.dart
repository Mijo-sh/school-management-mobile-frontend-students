import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/announcement_item.dart';
import '../../domain/use_cases/get_announcements_usecase.dart';
import '../../domain/use_cases/mark_announcement_as_read_usecase.dart';

part 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;
  final MarkAnnouncementAsReadUseCase markAnnouncementAsReadUseCase;
  final int? studentId;

  AnnouncementsCubit({
    required this.getAnnouncementsUseCase,
    required this.markAnnouncementAsReadUseCase,
    this.studentId,
  }) : super(const AnnouncementsInitial());

  Future<void> loadAnnouncements() async {
    emit(const AnnouncementsLoading());
    final result = await getAnnouncementsUseCase(studentId: studentId);
    result.fold(
          (failure) => emit(AnnouncementsError(failure.message)),
          (list) {
        emit(AnnouncementsLoaded(list));
        // 👇 فتح الشاشة نفسها = "شافهم كلهم" — نستدعي فورًا بدون
        // انتظار أي ضغط، بالخلفية بدون ما نعطل عرض القائمة.
        markAsRead();
      },
    );
  }

  Future<void> markAsRead() async {
    final current = state;
    if (current is! AnnouncementsLoaded) return;

    final hasUnread = current.announcements.any((a) => !a.isRead);
    if (!hasUnread) return;
    final result = await markAnnouncementAsReadUseCase(studentId: studentId);
    result.fold(
          (failure) {
        if (state is AnnouncementsLoaded) emit(current); // rollback بصمت
      },
          (_) {},
    );
  }
}