import 'package:bloc/bloc.dart';

import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/get_practice_subjects_usecase.dart';

abstract class SubjectsState {}
class SubjectsInitial extends SubjectsState {}
class SubjectsLoading extends SubjectsState {}
class SubjectsLoaded extends SubjectsState {
  final List<SubjectEntity> subjects;
  SubjectsLoaded(this.subjects);
}
class SubjectsError extends SubjectsState {
  final String message;
  SubjectsError(this.message);
}

class SubjectsCubit extends Cubit<SubjectsState> {
  final GetPracticeSubjectsUseCase getPracticeSubjectsUseCase;

  SubjectsCubit({required this.getPracticeSubjectsUseCase}) : super(SubjectsInitial());

  Future<void> fetchSubjects() async {
    emit(SubjectsLoading());
    final result = await getPracticeSubjectsUseCase();
    result.fold(
          (failure) => emit(SubjectsError(failure.message)),
          (subjects) => emit(SubjectsLoaded(subjects)),
    );
  }
}