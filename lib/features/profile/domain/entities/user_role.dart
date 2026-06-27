enum UserRole {
  student,
  guardian,
  unknown;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'guardian':
        return UserRole.guardian;
      default:
        return UserRole.unknown;
    }
  }
}