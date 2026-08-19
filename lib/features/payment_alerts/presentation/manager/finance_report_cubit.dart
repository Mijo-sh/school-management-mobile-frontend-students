import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_finance_report_usecase.dart';
import 'finance_report_state.dart';

class FinanceReportCubit extends Cubit<FinanceReportState> {
  final GetFinanceReportUseCase getFinanceReportUseCase;
  final int studentId;

  FinanceReportCubit({
    required this.getFinanceReportUseCase,
    required this.studentId,
  }) : super(const FinanceReportInitial());

  Future<void> loadReport() async {
    emit(const FinanceReportLoading());
    final result = await getFinanceReportUseCase(studentId: studentId);
    result.fold(
          (failure) => emit(FinanceReportError(failure.message)),
          (report) => emit(FinanceReportLoaded(report)),
    );
  }
}