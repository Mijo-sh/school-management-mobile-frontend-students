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
  final bool hasMore;

  const ActivitiesLoaded(this.activities, {this.hasMore = false});

  int get unreadCount => activities.where((a) => !a.isRead).length;

  ActivitiesLoaded copyWith({
    List<ActivityItem>? activities,
    bool? hasMore,
  }) {
    return ActivitiesLoaded(
      activities ?? this.activities,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [activities, hasMore];
}

class ActivitiesError extends ActivitiesState {
  final String message;
  const ActivitiesError(this.message);

  @override
  List<Object?> get props => [message];
}