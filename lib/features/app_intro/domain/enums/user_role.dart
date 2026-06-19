enum UserRole {
  student,
  parent
}

extension UserRoleX on UserRole {
  static UserRole? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'STUDENT':
        return UserRole.student;
      case 'PARENT':
        return UserRole.parent;
      default:
        return null;
    }
  }
}