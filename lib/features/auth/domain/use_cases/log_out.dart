import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/routing/selected_child_holder.dart';
import '../repositories/auth_repository.dart';

class LogOutUsecase {
  final SelectedChildHolder selectedChildHolder;
  final AuthRepository repository;

  LogOutUsecase(this.repository, {required this.selectedChildHolder});

  Future<Either<Failure, Unit>> call() async {
    final result = await repository.logout();
    selectedChildHolder.clear(); // 👈 نظّف الابن المختار بعد الخروج
    return result;
  }
}