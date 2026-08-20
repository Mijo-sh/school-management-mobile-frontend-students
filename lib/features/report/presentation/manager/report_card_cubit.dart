import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/unread_counts_store.dart';
import '../../domain/repositories/report_card_repository.dart';
import '../../domain/use_cases/get_report_card_usecase.dart';
import '../../domain/use_cases/mark_all_report_card_as_read_usecase.dart';
import 'report_card_state.dart';

class ReportCardCubit extends Cubit<ReportCardState> {
  final GetReportCardUseCase getReportCardUseCase;
  final MarkAllReportCardAsReadUseCase markReportCardAsReadUseCase; // 👈 جديد
  final int? studentId;
  int? reportCardId; // 👈 شلنا final

  ReportCardCubit({
    required this.getReportCardUseCase,
    required this.markReportCardAsReadUseCase, // 👈 جديد
    this.studentId,
    this.reportCardId,
  }) : super(const ReportCardInitial());

  Future<void> loadReportCard({int? reportCardId}) async {
    if (reportCardId != null) this.reportCardId = reportCardId;

    emit(const ReportCardLoading());

    final result = await getReportCardUseCase(
      studentId: studentId,
      reportCardId: this.reportCardId,
    );
    result.fold(
          (failure) {
        if (failure is EmptyReportCardFailure) {
          emit(ReportCardEmpty(failure.messageText));
        } else {
          emit(ReportCardError(_mapFailureToMessage(failure)));
        }
      },
          (reportCard) {
        emit(ReportCardLoaded(reportCard));
        _markAsReadAndClearBadge(); // 👈 بعد نجاح التحميل
      },
    );
  }

  // يصفّر البادج فورًا (UX) وينده mark-all-read بالخلفية
  bool _cleared = false;
  Future<void> _markAsReadAndClearBadge() async {
    if (_cleared) return; // مرة وحدة يكفّي حتى لو بدّل التبويبات
    _cleared = true;
    di<UnreadCountsStore>().clearReportCard();
    await markReportCardAsReadUseCase(studentId: studentId);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'حدث خطأ غير متوقّع، حاول مرة أخرى';
  }
}