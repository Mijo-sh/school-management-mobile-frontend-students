import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مخزن محلي بس (بدون أي مزامنة سيرفر حاليًا) لحالة "أنجزت الوظيفة"
/// — نفس مبدأ [SelectedChildHolder]/[UnreadCountsStore]: Singleton
/// عبر الـ DI، مش Provider بالشجرة، عشان يوصله أي مكان بالتطبيق
/// (الصفحة، البادج مستقبلًا لو حبينا...) بغض النظر عن موقعه بالشجرة.
///
/// ⚠️ ميزة الطالب نفسو بس (studentId == null) — ولي الأمر ما بيقدر
/// يأشّر وظائف ابنه، هاد بيتحدد بمستوى الواجهة (HomeworksPage)، مش
/// هون.
///
/// TODO مستقبلي: لو الباك إند ضاف endpoint حقيقي لتعليم الوظيفة
/// كمنجزة، بدّل هالـ Store ليندي طلب شبكة كمان (نفس نمط
/// AlertsCubit.markAsRead بالضبط) بدل الاكتفاء بالتخزين المحلي.
class HomeworkCompletionStore extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  HomeworkCompletionStore({required this.sharedPreferences});

  static const _keyPrefix = 'HOMEWORK_COMPLETED_IDS';

  String _keyFor(int? studentId) => '${_keyPrefix}_${studentId?.toString() ?? 'self'}';

  Set<int> _completedIds(int? studentId) {
    final jsonString = sharedPreferences.getString(_keyFor(studentId));
    if (jsonString == null) return {};
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((e) => e as int).toSet();
    } catch (_) {
      return {};
    }
  }

  bool isCompleted(int homeworkId, {int? studentId}) {
    return _completedIds(studentId).contains(homeworkId);
  }

  Future<void> toggle(int homeworkId, {int? studentId}) async {
    final ids = _completedIds(studentId);
    if (ids.contains(homeworkId)) {
      ids.remove(homeworkId);
    } else {
      ids.add(homeworkId);
    }
    await sharedPreferences.setString(_keyFor(studentId), jsonEncode(ids.toList()));
    notifyListeners();
  }
}
