
enum AlertType {
  homework,
  absence,
  behavior,
  late,
  escape,
  general;

  static AlertType fromApiValue(String? value) {
    switch (value) {
      case 'homework':
        return AlertType.homework;
      case 'absence':
        return AlertType.absence;
      case 'behavior':
        return AlertType.behavior;
      case 'late':
        return AlertType.late;
      case 'escape':
        return AlertType.escape;
      default:
        return AlertType.general;
    }
  }
}
