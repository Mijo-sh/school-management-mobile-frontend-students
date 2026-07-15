import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProfilePictureEvent extends Equatable {
  const ProfilePictureEvent();

  @override
  List<Object?> get props => [];
}

/// يُرسَل عند ضغط المستخدم على "متابعة" بعد اختيار صورة.
class SaveProfilePictureRequested extends ProfilePictureEvent {
  final File image;

  const SaveProfilePictureRequested(this.image);

  @override
  List<Object?> get props => [image.path];
}

/// يُرسَل عند ضغط المستخدم على "تخطي الآن" — بيعتبر قرار نهائي
/// (يحدّث isPicChoose=true بجلسة التطبيق برضو).
class SkipProfilePictureRequested extends ProfilePictureEvent {
  const SkipProfilePictureRequested();
}

/// يُرسَل لجلب الصورة المحفوظة سابقًا (مثلاً بصفحة البروفايل).
class LoadProfilePictureRequested extends ProfilePictureEvent {
  const LoadProfilePictureRequested();
}

/// يُرسَل لحذف الصورة المحفوظة.
class DeleteProfilePictureRequested extends ProfilePictureEvent {
  const DeleteProfilePictureRequested();
}