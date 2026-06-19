enum UserRole {
  teacher,
  counselor
}

extension UserRoleX on UserRole {
  static UserRole? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'TEACHER':
        return UserRole.teacher;
      case 'COUNSELOR':
        return UserRole.counselor;
      default:
        return null;
    }
  }
}