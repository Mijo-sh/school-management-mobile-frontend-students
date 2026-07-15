import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'خطأ في الخادم، حاول مجدداً']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطأ في التخزين المحلي']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message='validation failure']);
}
class OfflineFailure extends Failure {
  OfflineFailure([super.message='offline failure']);
}

class EmptyCacheFailure extends Failure {
  EmptyCacheFailure([super.message='EmptyCache failure']);
}

class UnExpectedFailure extends Failure {
  UnExpectedFailure([super.message='UnExpectedFailure']);
}

