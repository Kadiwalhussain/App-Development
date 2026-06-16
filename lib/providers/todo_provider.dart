import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

enum FilterType { all, active, completed }

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  FilterType _filter = FilterType.all;
  Category? _categoryFilter;
  String _searchQuery = '';
  bool _isDarkMode = false;

  static const _storageKey = 'todos_v1';
  static const _themeKey = 'dark_mode';

  List<Todo> get todos => _filteredTodos;
  FilterType get filter => _filter;
  Category? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  int get overdueCount => _todos.where((t) => t.isOverdue).length;

  List<Todo> get _filteredTodos {
    var list = List<Todo>.from(_todos);

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_categoryFilter != null) {
      list = list.where((t) => t.category == _categoryFilter).toList();
    }

    switch (_filter) {
      case FilterType.active:
        list = list.where((t) => !t.isCompleted).toList();
        break;
      case FilterType.completed:
        list = list.where((t) => t.isCompleted).toList();
        break;
      case FilterType.all:
        break;
    }

    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final priorityOrder = {
        Priority.high: 0,
        Priority.medium: 1,
        Priority.low: 2
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return list;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    if (data != null) {
      _todos = Todo.decodeList(data);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Todo.encodeList(_todos));
  }

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
    _save();
    notifyListeners();
  }

  void updateTodo(Todo updated) {
    final idx = _todos.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _todos[idx] = updated;
      _save();
      notifyListeners();
    }
  }

  void toggleTodo(String id) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _todos[idx] = _todos[idx].copyWith(isCompleted: !_todos[idx].isCompleted);
      _save();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void clearCompleted() {
    _todos.removeWhere((t) => t.isCompleted);
    _save();
    notifyListeners();
  }

  void setFilter(FilterType filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(Category? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
