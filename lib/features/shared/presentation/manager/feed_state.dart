import 'package:equatable/equatable.dart';

abstract class FeedState<T> extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial<T> extends FeedState<T> {
  const FeedInitial();
}

class FeedLoading<T> extends FeedState<T> {
  const FeedLoading();
}

class FeedLoaded<T> extends FeedState<T> {
  final List<T> items;
  final bool hasMore;
  const FeedLoaded(this.items, {required this.hasMore});

  @override
  List<Object?> get props => [items, hasMore];
}

class FeedError<T> extends FeedState<T> {
  final String message;
  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
