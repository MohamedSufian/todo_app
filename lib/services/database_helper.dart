import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

/// طبقة مسؤولة عن كل التعامل مع قاعدة بيانات SQLite (CRUD كامل).
/// نستخدم نمط Singleton حتى يكون في اتصال واحد فقط بقاعدة البيانات
/// طول عمر التطبيق، بدل ما نفتح اتصال جديد كل مرة.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'todo_app.db';
  // رفعنا النسخة من 1 إلى 2 لما ضفنا عمود category (تصنيف المهمة).
  static const int _dbVersion = 2;
  static const String tableTasks = 'tasks';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER NOT NULL DEFAULT 1,
        category INTEGER NOT NULL DEFAULT 3,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Migration: لو المستخدم أصلاً عنده تطبيق مركّب بنسخة قديمة (version 1)
  /// بدون عمود category، هذا الكود بيضيفه له بدون ما يخسر أي مهمة موجودة.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableTasks ADD COLUMN category INTEGER NOT NULL DEFAULT 3',
      );
    }
  }

  // ---------------- CRUD ----------------

  /// إضافة مهمة جديدة. بترجع نفس المهمة بس معبّى فيها الـ id يلي ولّدته SQLite.
  Future<Task> insertTask(Task task) async {
    final db = await database;
    final map = task.toMap()..remove('id');
    final id = await db.insert(tableTasks, map);
    return task.copyWith(id: id);
  }

  /// كل المهام، الأحدث إضافة أول شي.
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final result = await db.query(tableTasks, orderBy: 'created_at DESC');
    return result.map(Task.fromMap).toList();
  }

  /// مهمة واحدة حسب الـ id، أو null إذا مش موجودة.
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query(
      tableTasks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Task.fromMap(result.first);
  }

  /// تحديث مهمة موجودة (لازم يكون عندها id).
  Future<int> updateTask(Task task) async {
    assert(task.id != null, 'ما بتقدر تحدّث مهمة بدون id');
    final db = await database;
    return db.update(
      tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// حذف مهمة حسب الـ id.
  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(tableTasks, where: 'id = ?', whereArgs: [id]);
  }

  /// حذف كل المهام (مفيدة للاختبار أو خيار "مسح الكل").
  Future<int> deleteAllTasks() async {
    final db = await database;
    return db.delete(tableTasks);
  }
}
