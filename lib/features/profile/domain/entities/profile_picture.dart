import 'package:equatable/equatable.dart';

/// يمثّل حالة الصورة الشخصية: مسارها المحلي (دائمًا موجود بعد الحفظ)
/// ورابطها على السيرفر (قد يكون null لو ما فيه نت وقت الحفظ، أو فشل الرفع).
class ProfilePicture extends Equatable {
  final String localPath;
  final String? remoteUrl;

  const ProfilePicture({required this.localPath, this.remoteUrl});

  @override
  List<Object?> get props => [localPath, remoteUrl];
}
