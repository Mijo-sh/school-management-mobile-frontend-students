// lib/features/complaint/presentation/bloc/complaint_event.dart

part of 'complaint_bloc.dart';

abstract class ComplaintEvent extends Equatable {
  const ComplaintEvent();
  @override
  List<Object?> get props => [];
}

/// جلب شكاوى طالب معيّن.
class GetComplaintsEvent extends ComplaintEvent {
  final int studentId;
  const GetComplaintsEvent(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

/// جلب خيارات الشكاوى (التصنيفات والأنواع).
class GetComplaintOptionsEvent extends ComplaintEvent {
  const GetComplaintOptionsEvent();
}

/// إنشاء شكوى جديدة.
class CreateComplaintEvent extends ComplaintEvent {
  final int studentId;
  final int complaintTypeId;
  const CreateComplaintEvent({
    required this.studentId,
    required this.complaintTypeId,
  });
  @override
  List<Object?> get props => [studentId, complaintTypeId];
}
/// حذف شكوى.
class DeleteComplaintEvent extends ComplaintEvent {
  final int complaintId;
  const DeleteComplaintEvent(this.complaintId);
  @override
  List<Object?> get props => [complaintId];
}
