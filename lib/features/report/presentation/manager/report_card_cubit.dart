import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/report_card_repository.dart';
import '../../domain/use_cases/get_report_card_usecase.dart';
import 'report_card_state.dart';

class ReportCardCubit extends Cubit<ReportCardState> {
  final GetReportCardUseCase getReportCardUseCase;
  final int? studentId;
  final int? reportCardId;

  ReportCardCubit({
    required this.getReportCardUseCase,
    this.studentId,
    this.reportCardId,
  }) : super(const ReportCardInitial());

  Future<void> loadReportCard() async {
    emit(const ReportCardLoading());

    final result = await getReportCardUseCase(
      studentId: studentId,
      reportCardId: reportCardId,
    );
    result.fold(
          (failure) {
        if (failure is EmptyReportCardFailure) {
          emit(ReportCardEmpty(failure.messageText));
        } else {
          emit(ReportCardError(_mapFailureToMessage(failure)));
        }
      },
          (reportCard) => emit(ReportCardLoaded(reportCard)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'حدث خطأ غير متوقّع، حاول مرة أخرى';
  }
}