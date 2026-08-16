// lib/features/complaint/presentation/bloc/complaint_state.dart

part of 'complaint_bloc.dart';

enum ComplaintStatus { initial, loading, success, failure }

class ComplaintState extends Equatable {
  final List<Complaint> complaints;
  final List<ComplaintCategory> categories;
  final ComplaintStatus listStatus;
  final ComplaintStatus optionsStatus;
  final ComplaintStatus submissionStatus;
  final String? message;

  const ComplaintState({
    this.complaints = const [],
    this.categories = const [],
    this.listStatus = ComplaintStatus.initial,
    this.optionsStatus = ComplaintStatus.initial,
    this.submissionStatus = ComplaintStatus.initial,
    this.message,
  });

  ComplaintState copyWith({
    List<Complaint>? complaints,
    List<ComplaintCategory>? categories,
    ComplaintStatus? listStatus,
    ComplaintStatus? optionsStatus,
    ComplaintStatus? submissionStatus,
    String? message,
    bool clearMessage = false,
  }) {
    return ComplaintState(
      complaints: complaints ?? this.complaints,
      categories: categories ?? this.categories,
      listStatus: listStatus ?? this.listStatus,
      optionsStatus: optionsStatus ?? this.optionsStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        complaints,
        categories,
        listStatus,
        optionsStatus,
        submissionStatus,
        message,
      ];
}
