import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_picture.dart';

abstract class ProfilePictureState extends Equatable {
  const ProfilePictureState();

  @override
  List<Object?> get props => [];
}

class ProfilePictureInitial extends ProfilePictureState {
  const ProfilePictureInitial();
}

class ProfilePictureLoading extends ProfilePictureState {
  const ProfilePictureLoading();
}

/// نتيجة عملية الحفظ. الصورة محفوظة محليًا دائمًا هون؛
/// [ProfilePicture.remoteUrl] بيكون null لو ما فيه نت أو فشل الرفع.
class ProfilePictureSaved extends ProfilePictureState {
  final ProfilePicture picture;

  const ProfilePictureSaved(this.picture);

  bool get uploadedToServer => picture.remoteUrl != null;

  @override
  List<Object?> get props => [picture];
}

/// المستخدم ضغط "تخطي الآن" — قرار نهائي، isPicChoose صار true.
class ProfilePictureSkipped extends ProfilePictureState {
  const ProfilePictureSkipped();
}

/// نتيجة جلب الصورة المحفوظة (picture == null يعني ما فيه صورة).
class ProfilePictureLoaded extends ProfilePictureState {
  final ProfilePicture? picture;

  const ProfilePictureLoaded(this.picture);

  @override
  List<Object?> get props => [picture];
}

class ProfilePictureDeleted extends ProfilePictureState {
  const ProfilePictureDeleted();
}

class ProfilePictureError extends ProfilePictureState {
  final String message;

  const ProfilePictureError(this.message);

  @override
  List<Object?> get props => [message];
}