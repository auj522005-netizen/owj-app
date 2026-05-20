import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  String priority; // high, medium, low
  String category;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.dueDate,
    this.priority = 'medium',
    this.category = 'عام',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'isCompleted': isCompleted, 'dueDate': dueDate.toIso8601String(),
    'priority': priority, 'category': category,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'], title: json['title'], description: json['description'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
    dueDate: DateTime.parse(json['dueDate']),
    priority: json['priority'] ?? 'medium',
    category: json['category'] ?? 'عام',
  );
}

class TasksProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<Task> _tasks = [];

  TasksProvider(this.prefs) { _loadTasks(); }

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get todayTasks => _tasks.where((t) {
    final now = DateTime.now();
    return t.dueDate.year == now.year && t.dueDate.month == now.month && t.dueDate.day == now.day;
  }).toList();

  void _loadTasks() {
    final data = prefs.getString('tasks');
    if (data != null) {
      _tasks = (jsonDecode(data) as List).map((e) => Task.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveTasks() {
    prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) { _tasks[idx] = task; _saveTasks(); notifyListeners(); }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasks.length / _tasks.length;
  }
}
