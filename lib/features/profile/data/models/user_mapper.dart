// data/models/user_mapper.dart
import 'user_model.dart';
import 'student_model.dart';
import 'parent_model.dart';

class UserMapper {
  UserMapper._(); // منع الـ instantiation

  static UserModel fromJson(Map<String, dynamic> json) {
    final roleStr = _resolveRole(json);

    switch (roleStr) {
      case 'student':
        return StudentModel.fromJson(json);
      case 'parent':
        return ParentModel.fromJson(json);
      default:
      // بدل ما يـ crash بصمت، نرمي exception واضح
        throw UnimplementedError('Role غير معروف: $roleStr');
    }
  }

  static String _resolveRole(Map<String, dynamic> json) {
    // Laravel عادةً يرجع role_name كـ string
    if (json['role_name'] != null) {
      return (json['role_name'] as String).toLowerCase().trim();
    }
    // fallback على role_id
    final roleId = json['role_id']?.toString();
    if (roleId == '1') return 'student';
    if (roleId == '2') return 'parent';

    throw ArgumentError('JSON لا يحتوي على role_name أو role_id صالح');
  }
}