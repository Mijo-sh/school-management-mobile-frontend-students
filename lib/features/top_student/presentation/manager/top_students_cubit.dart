import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/top_student.dart';
import '../../domain/use_cases/get_top_students_usecase.dart';

part 'top_students_state.dart';

class TopStudentsCubit extends Cubit<TopStudentsState> {
  final GetTopStudentsUseCase getTopStudentsUseCase;
  final int? studentId;

  TopStudentsCubit({
    required this.getTopStudentsUseCase,
    this.studentId,
  }) : super(TopStudentsInitial());

  // كاش لكل فصل حتى ما نعيد الطلب عند تبديل التبويب
  final Map<int, List<TopStudent>> _cache = {};

  Future<void> loadTopStudents({required int semesterId}) async {
    // إذا موجود بالكاش، اعرضه مباشرة
    if (_cache.containsKey(semesterId)) {
      emit(TopStudentsLoaded(_cache[semesterId]!));
      return;
    }

    emit(TopStudentsLoading());
    final result = await getTopStudentsUseCase(
      semesterId: semesterId,
      studentId: studentId,
    );
    result.fold(
          (failure) => emit(TopStudentsError(failure.message)),
          (students) {
        _cache[semesterId] = students;
        emit(TopStudentsLoaded(students));
      },
    );
  }

  // لإعادة المحاولة أو التحديث القسري (يتخطى الكاش)
  Future<void> refresh({required int semesterId}) async {
    _cache.remove(semesterId);
    await loadTopStudents(semesterId: semesterId);
  }
}