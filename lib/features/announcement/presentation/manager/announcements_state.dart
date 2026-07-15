part of 'announcements_cubit.dart';

abstract class AnnouncementsState extends Equatable {
  const AnnouncementsState();

  @override
  List<Object?> get props => [];
}

class AnnouncementsInitial extends AnnouncementsState {
  const AnnouncementsInitial();
}

class AnnouncementsLoading extends AnnouncementsState {
  const AnnouncementsLoading();
}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<AnnouncementItem> announcements;
  const AnnouncementsLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements];
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  const AnnouncementsError(this.message);

  @override
  List<Object?> get props => [message];
}
