/// أولوية المهمة
enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'منخفضة';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.high:
        return 'عالية';
    }
  }
}

/// تصنيف المهمة
enum TaskCategory {
  work,
  study,
  personal,
  other;

  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'عمل';
      case TaskCategory.study:
        return 'دراسة';
      case TaskCategory.personal:
        return 'شخصي';
      case TaskCategory.other:
        return 'أخرى';
    }
  }
}

/// نموذج بيانات المهمة الواحدة.
/// [id] بيكون null لمهمة جديدة لسا ما انحفظت بقاعدة البيانات؛
/// SQLite هي يلي بتولّد الـ id تلقائيًا (AUTOINCREMENT) بعد أول insert.
class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskCategory category;
  final bool isDone;
  final DateTime createdAt;

  const Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.isDone = false,
    required this.createdAt,
  });

  /// نسخة معدّلة من المهمة (مفيدة للتعديل أو لتحديث حالة الإنجاز)
  /// بدون تغيير باقي الحقول.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskPriority? priority,
    TaskCategory? category,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحويل المهمة إلى Map حتى نقدر نخزنها بجدول SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// بناء مهمة من صف (Row) راجع من قاعدة البيانات.
  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] == null
          ? null
          : DateTime.parse(map['due_date'] as String),
      priority: TaskPriority.values[(map['priority'] as int?) ?? 1],
      category: TaskCategory.values[(map['category'] as int?) ?? 3],
      isDone: ((map['is_done'] as int?) ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
