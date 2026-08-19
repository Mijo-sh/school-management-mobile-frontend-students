// lib/features/complaint/presentation/bloc/complaint_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/complaint_entities.dart';
import '../../domain/use_cases/delete_complaint_usecase.dart';
import '../../domain/use_cases/get_complaint_options_usecase.dart';
import '../../domain/use_cases/get_complaints_usecase.dart';
import '../../domain/use_cases/create_complaint_usecase.dart';

part 'complaint_event.dart';
part 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final GetComplaintsUseCase getComplaints;
  final GetComplaintOptionsUseCase getOptions;
  final CreateComplaintUseCase createComplaint;
  final DeleteComplaintUseCase deleteComplaint; // 👈 جديد

  // نحتفظ بآخر studentId لإعادة جلب القائمة بعد الإنشاء.
  int? _lastStudentId;

  ComplaintBloc({
    required this.getComplaints,
    required this.getOptions,
    required this.createComplaint,
    required this.deleteComplaint, // 👈 جديد

  }) : super(const ComplaintState()) {
    on<GetComplaintsEvent>(_onGetComplaints);
    on<GetComplaintOptionsEvent>(_onGetOptions);
    on<CreateComplaintEvent>(_onCreateComplaint);
    on<DeleteComplaintEvent>(_onDeleteComplaint); // 👈 جديد

  }

  Future<void> _onGetComplaints(
    GetComplaintsEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    _lastStudentId = event.studentId;
    emit(state.copyWith(listStatus: ComplaintStatus.loading, clearMessage: true));
    final result = await getComplaints(event.studentId);
    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: ComplaintStatus.failure,
        message: _msg(failure),
      )),
      (complaints) => emit(state.copyWith(
        listStatus: ComplaintStatus.success,
        complaints: complaints,
      )),
    );
  }

  Future<void> _onGetOptions(
    GetComplaintOptionsEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(state.copyWith(optionsStatus: ComplaintStatus.loading, clearMessage: true));
    final result = await getOptions();
    result.fold(
      (failure) => emit(state.copyWith(
        optionsStatus: ComplaintStatus.failure,
        message: _msg(failure),
      )),
      (categories) => emit(state.copyWith(
        optionsStatus: ComplaintStatus.success,
        categories: categories,
      )),
    );
  }
// داخل دالة _onCreateComplaint في complaint_bloc.dart[cite: 7]
  Future<void> _onCreateComplaint(
      CreateComplaintEvent event,
      Emitter<ComplaintState> emit,
      ) async {
    emit(state.copyWith(
      submissionStatus: ComplaintStatus.loading,
      clearMessage: true,
    ));
    final result = await createComplaint(
      ComplaintToCreate(
        studentId: event.studentId,
        complaintTypeId: event.complaintTypeId,
      ),
    );
    await result.fold(
          (failure) async {
        // 🔍 تتبع ما وصل للـ Bloc
        print('🎯 [BLOC] Failure type: ${failure.runtimeType}');
        if (failure is ServerFailure) {
          print('🎯 [BLOC] ServerFailure message: "${failure.message}"');
        }

        emit(state.copyWith(
          submissionStatus: ComplaintStatus.failure,
          message: _msg(failure),
        ));
      },
          (_) async {
        emit(state.copyWith(
          submissionStatus: ComplaintStatus.success,
          message: 'تم إرسال الشكوى',
        ));
        final sid = _lastStudentId ?? event.studentId;
        add(GetComplaintsEvent(sid));
      },
    );
  }

  String _msg(Failure failure) {
    if (failure is ServerFailure) {
      // التحقق مما إذا كانت الرسالة موجودة وليست فارغة، وإلا إرجاع رسالة افتراضية واضحة
      if (failure.message.isNotEmpty) {
        return failure.message;
      }
      return 'حدث خطأ في الخادم، حاول مرة أخرى';
    }
    if (failure is UnExpectedFailure) {
      return failure.message.isNotEmpty ? failure.message : 'حدث خطأ غير متوقع';
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }
  Future<void> _onDeleteComplaint(
      DeleteComplaintEvent event,
      Emitter<ComplaintState> emit,
      ) async {
    emit(state.copyWith(
      submissionStatus: ComplaintStatus.loading,
      clearMessage: true,
    ));
    final result = await deleteComplaint(event.complaintId);
    await result.fold(
          (failure) async {
        emit(state.copyWith(
          submissionStatus: ComplaintStatus.failure,
          message: _msg(failure),
        ));
      },
          (_) async {
        emit(state.copyWith(
          submissionStatus: ComplaintStatus.success,
          message: 'تم حذف الشكوى',
        ));
        final sid = _lastStudentId;
        if (sid != null) add(GetComplaintsEvent(sid));
      },
    );
  }
}
