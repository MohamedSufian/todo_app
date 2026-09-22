import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/database_helper.dart';

/// يدير قائمة المهام بالذاكرة، ويتوسط بين الشاشات وقاعدة البيانات.
/// أي شاشة "تستمع" لهذا الـ Provider بترسم نفسها من جديد تلقائيًا
/// كل ما تتغير قائمة المهام (إضافة / تعديل / حذف / تبديل حالة الإنجاز).
class TaskProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _db.getAllTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final inserted = await _db.insertTask(task);
    _tasks.insert(0, inserted);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> toggleDone(Task task) async {
    await updateTask(task.copyWith(isDone: !task.isDone));
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;
    await _db.deleteTask(task.id!);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }
}
