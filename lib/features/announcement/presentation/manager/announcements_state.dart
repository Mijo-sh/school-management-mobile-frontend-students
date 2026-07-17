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
  final bool hasMore;

  const AnnouncementsLoaded(this.announcements, {this.hasMore = false});

  /// حساب عدد الإعلانات غير المقروءة في القائمة الحالية تلقائياً
  int get unreadCount => announcements.where((a) => !a.isRead).length;

  AnnouncementsLoaded copyWith({
    List<AnnouncementItem>? announcements,
    bool? hasMore,
  }) {
    return AnnouncementsLoaded(
      announcements ?? this.announcements,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [announcements, hasMore];
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  const AnnouncementsError(this.message);

  @override
  List<Object?> get props => [message];
}