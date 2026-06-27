import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/child_card.dart';
import '../../domain/use_cases/get_children_usecase.dart';

part 'guardian_state.dart';

class GuardianCubit extends Cubit<GuardianState> {
  final GetChildrenUsecase getChildrenUsecase;

  GuardianCubit({required this.getChildrenUsecase})
      : super(const GuardianInitial());

  Future<void> loadChildren() async {
    emit(const GuardianLoading());
    final result = await getChildrenUsecase();
    result.fold(
      (failure) => emit(GuardianError(failure.message)),
      (children) => emit(GuardianLoaded(children)),
    );
  }
}
