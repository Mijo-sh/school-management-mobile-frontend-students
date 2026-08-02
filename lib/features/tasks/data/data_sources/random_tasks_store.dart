import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/random_task.dart';
import 'task_reminder_service.dart';

class RandomTasksStore extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final TaskReminderService reminderService;

  RandomTasksStore({required this.sharedPreferences, required this.reminderService});

  static const _key = 'RANDOM_TASKS';

  List<RandomTask> _tasks = [];
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      try {
        final list = jsonDecode(jsonString) as List<dynamic>;
        _tasks = list.map((e) => RandomTask.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _tasks = [];
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final jsonString = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await sharedPreferences.setString(_key, jsonString);
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// كل المهام، مرتّبة حسب التاريخ (الأقرب أول).
  List<RandomTask> get allTasks {
    final sorted = [..._tasks];
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(sorted);
  }

  /// مهام اليوم الحالي بس — للشريط الأفقي بالداشبورد.
  List<RandomTask> get todayTasks => _tasks.where((t) => _sameDay(t.date, DateTime.now())).toList();

  Future<void> addTask({required String title, required String description, required DateTime date}) async {
    final task = RandomTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      isDone: false,
    );
    _tasks.add(task);
    await _persist();
    notifyListeners();

    // جدولة التذكير بالخلفية — ما بيوقف عملية الإضافة لو فشلت الجدولة.
    try {
      await reminderService.scheduleReminder(task);
    } catch (_) {}
  }

  /// تحديث مهمة موجودة مسبقاً
  Future<void> updateTask(RandomTask updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return;

    _tasks[index] = updatedTask;
    await _persist();
    notifyListeners();

    // تحديث التذكير بالخلفية إن أمكن
    try {
      await reminderService.scheduleReminder(updatedTask);
    } catch (_) {}
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
    try {
      await reminderService.cancelReminder(id);
    } catch (_) {}
  }
  // تثبيت الحالة وإقفالها لمرة واحدة
  Future<void> setStatus(String id, bool isDone) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1 || _tasks[index].isLocked) return; // ممنوع التعديل إذا كانت مقفولة

    _tasks[index] = _tasks[index].copyWith(
      isDone: isDone,
      isLocked: true, // إقفال الخيار نهائياً
    );
    await _persist();
    notifyListeners();
  }
}