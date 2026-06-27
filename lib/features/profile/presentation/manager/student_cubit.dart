import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/use_cases/get_cached_user_usecase.dart';
import '../../domain/use_cases/get_student_usecase.dart';

part 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  final GetAcademicInfoUsecase getAcademicInfoUsecase;
  final GetCachedUserUsecase getCachedUserUsecase;

  StudentCubit({
    required this.getAcademicInfoUsecase,
    required this.getCachedUserUsecase,
  }) : super(const StudentInitial());

  Future<void> loadStudentData() async {
    emit(const StudentLoading());

    // 1) اسم الطالب من التخزين المحلي (يشتغل حتى لو مسجّل من قبل)
    final userResult = await getCachedUserUsecase();
    String studentName = '';
    userResult.fold(
          (_) => studentName = '',
          (user) => studentName = user?.fullName ?? '',
    );

    // 2) المعلومات الأكاديمية من السيرفر
    final infoResult = await getAcademicInfoUsecase();
    infoResult.fold(
          (failure) => emit(StudentError(failure.message)),
          (info) => emit(StudentLoaded(
        studentName: studentName,
        academicInfo: info,
      )),
    );
  }
}