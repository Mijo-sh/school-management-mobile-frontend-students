class ApiEndpoints {
  static const baseUrl = 'http://10.141.38.242:8000';
  // -------------------- Auth --------------------
  static const String sendCode = '/auth/loginMobile';
  static const String verifyCode = '/auth/verify-otp-mobile';
  static const String logout = '/auth/logout';
  static const String uploadProfilePicture = '/api/auth/personal-image';
}