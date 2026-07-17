class ApiEndpoints {
  static const baseUrl = 'http://192.168.1.103:8000';

  // -------------------- Auth --------------------
  static const String sendCode = '/auth/loginMobile';
  static const String verifyCode = '/auth/verify-otp-mobile';
  static const String logout = '/auth/logout';
  static const String uploadProfilePicture = '/api/auth/personal-image';
}