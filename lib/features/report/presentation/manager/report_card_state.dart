import 'package:equatable/equatable.dart';
import '../../domain/entities/report_card.dart';

abstract class ReportCardState extends Equatable {
  const ReportCardState();
  @override
  List<Object?> get props => [];
}

class ReportCardInitial extends ReportCardState {
  const ReportCardInitial();
}

class ReportCardLoading extends ReportCardState {
  const ReportCardLoading();
}

class ReportCardLoaded extends ReportCardState {
  final ReportCard reportCard;
  const ReportCardLoaded(this.reportCard);
  @override
  List<Object?> get props => [reportCard];
}

class ReportCardError extends ReportCardState {
  final String message;
  const ReportCardError(this.message);
  @override
  List<Object?> get props => [message];
}
class ReportCardEmpty extends ReportCardState {
  final String message;
  const ReportCardEmpty(this.message);
  @override
  List<Object?> get props => [message];
}