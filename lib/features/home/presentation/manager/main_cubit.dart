import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/user_role.dart';
import '../../../profile/domain/use_cases/get_cached_user_usecase.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  final GetCachedUserUsecase getCachedUserUsecase;

  MainCubit({required this.getCachedUserUsecase}) : super(const MainInitial());

  Future<void> loadRole() async {
    emit(const MainLoading());
    final result = await getCachedUserUsecase();
    result.fold(
      (failure) => emit(MainError(failure.message)),
      (user) {
        if (user == null) {
          emit(const MainError('لم يتم العثور على بيانات المستخدم'));
        } else {
          emit(MainRoleLoaded(user.primaryRole));
        }
      },
    );
  }
}
