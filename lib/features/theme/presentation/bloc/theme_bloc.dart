import '../../domain/use_cases/save_theme_use_case.dart';
import '../../domain/use_cases/get_theme_use_case.dart';
import '../../domain/enums/theme_type.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetThemeUseCase getTheme;
  final SaveThemeUseCase saveTheme;

  ThemeBloc({
    required this.getTheme,
    required this.saveTheme
  }) : super(ThemeState.initial()) {
    on<GetThemeEvent>(_onGetThemeEvent);
    on<ToggleThemeEvent>(_onToggleThemeEvent);
  }

  Future<void> _onGetThemeEvent(
    GetThemeEvent event,
    Emitter<ThemeState> emit
    ) async {
    emit(state.copyWith(status: ThemeStatus.loading));
    try {
      final theme = await getTheme();
      emit(state.copyWith(
        status: ThemeStatus.success,
        type: theme,
        clearError: true
      ));

    } catch(e) {
      emit(state.copyWith(
        status: ThemeStatus.error,
        errorMessage: e.toString()
      ));
    }
  }

  Future<void> _onToggleThemeEvent(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit
    ) async {
    try {
      final newTheme = state.type == ThemeType.light ? ThemeType.dark : ThemeType.light;
      await saveTheme(newTheme);
      emit(state.copyWith(
        status: ThemeStatus.success,
        type: newTheme,
        clearError: true
      ));

    } catch(e) {
      emit(state.copyWith(
        status: ThemeStatus.error,
        errorMessage: e.toString()
      ));
    }
  }
}