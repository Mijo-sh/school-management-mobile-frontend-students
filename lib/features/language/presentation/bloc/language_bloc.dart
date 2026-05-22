import '../../domain/use_cases/save_language_use_case.dart';
import '../../domain/use_cases/get_language_use_case.dart';
import '../../domain/enums/language_type.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final GetLanguageUseCase getLanguage;
  final SaveLanguageUseCase saveLanguage;

  LanguageBloc({
    required this.getLanguage,
    required this.saveLanguage
  }) : super(LanguageState.initial()) {
    on<GetLanguageEvent>(_onGetLanguageEvent);
    on<ToggleLanguageEvent>(_onToggleLanguageEvent);
  }

  Future<void> _onGetLanguageEvent(
    GetLanguageEvent event,
    Emitter<LanguageState> emit
  ) async {
    emit(state.copyWith(status: LanguageStatus.loading));
    try {
      final language = await getLanguage();
      emit(state.copyWith(
        status: LanguageStatus.success,
        type: language,
        clearError: true
      ));

    } catch(e) {
      emit(state.copyWith(
        status: LanguageStatus.error,
        errorMessage: e.toString()
      ));
    }
  }

  Future<void> _onToggleLanguageEvent(
    ToggleLanguageEvent event,
    Emitter<LanguageState> emit
  ) async {
    try {
      final newLanguage = state.type == LanguageType.ar ? LanguageType.en : LanguageType.ar;
      await saveLanguage(newLanguage);
      emit(state.copyWith(
        status: LanguageStatus.success,
        type: newLanguage,
        clearError: true
      ));

    } catch(e) {
      emit(state.copyWith(
        status: LanguageStatus.error,
        errorMessage: e.toString()
      ));
    }
  }
}