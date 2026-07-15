part of 'activities_cubit.dart';

abstract class ActivitiesState extends Equatable {
  const ActivitiesState();

  @override
  List<Object?> get props => [];
}

class ActivitiesInitial extends ActivitiesState {
  const ActivitiesInitial();
}

class ActivitiesLoading extends ActivitiesState {
  const ActivitiesLoading();
}

class ActivitiesLoaded extends ActivitiesState {
  final List<ActivityItem> activities;
  const ActivitiesLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivitiesError extends ActivitiesState {
  final String message;
  const ActivitiesError(this.message);

  @override
  List<Object?> get props => [message];
}
