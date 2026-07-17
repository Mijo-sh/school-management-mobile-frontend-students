import '../../domain/entities/profile_picture.dart';

class ProfilePictureModel extends ProfilePicture {
  const ProfilePictureModel({
    required String localPath,
    String? remoteUrl,
  }) : super(localPath: localPath, remoteUrl: remoteUrl);

  factory ProfilePictureModel.fromJson(Map<String, dynamic> json) {
    return ProfilePictureModel(
      // تأكد أن أسماء الـ keys في الـ JSON تطابق ما يرسله السيرفر
      localPath: json['local_path'] ?? '',
      remoteUrl: json['remote_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_path': localPath,
      'remote_url': remoteUrl,
    };
  }
}