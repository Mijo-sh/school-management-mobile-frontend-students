import '../../domain/entities/finance_report.dart';

abstract class FinanceReportState {
  const FinanceReportState();
}

class FinanceReportInitial extends FinanceReportState {
  const FinanceReportInitial();
}

class FinanceReportLoading extends FinanceReportState {
  const FinanceReportLoading();
}

class FinanceReportLoaded extends FinanceReportState {
  final FinanceReport report;
  const FinanceReportLoaded(this.report);
}

class FinanceReportError extends FinanceReportState {
  final String message;
  const FinanceReportError(this.message);
}