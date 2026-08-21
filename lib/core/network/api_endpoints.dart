class ApiEndpoints {
  static const baseUrl = 'https://school-management-system-api-production-6ecb.up.railway.app';
  // -------------------- Auth --------------------
  static const String sendCode = '/auth/loginMobile';
  static const String verifyCode = '/auth/verify-otp-mobile';
  static const String logout = '/auth/logout';
  static const String uploadProfilePicture = '/api/auth/personal-image';
}