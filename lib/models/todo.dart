import 'dart:convert';

enum Priority { low, medium, high }

enum Category { personal, work, shopping, health, education, other }

class Todo {
  final String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  Category category;
  DateTime? dueDate;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = Category.personal,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    Category? category,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.index,
        'category': category.index,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        priority: Priority.values[json['priority'] ?? 1],
        category: Category.values[json['category'] ?? 0],
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );

  static String encodeList(List<Todo> todos) =>
      jsonEncode(todos.map((t) => t.toJson()).toList());

  static List<Todo> decodeList(String data) =>
      (jsonDecode(data) as List).map((j) => Todo.fromJson(j)).toList();
}
