import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goal {
  final String id;
  String title;
  String description;
  double progress;
  DateTime deadline;
  bool isCompleted;
  List<String> milestones;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.progress = 0.0,
    required this.deadline,
    this.isCompleted = false,
    this.milestones = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'progress': progress, 'deadline': deadline.toIso8601String(),
    'isCompleted': isCompleted, 'milestones': milestones,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'], title: json['title'], description: json['description'] ?? '',
    progress: (json['progress'] ?? 0.0).toDouble(),
    deadline: DateTime.parse(json['deadline']),
    isCompleted: json['isCompleted'] ?? false,
    milestones: List<String>.from(json['milestones'] ?? []),
  );
}

class GoalsProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<Goal> _goals = [];

  GoalsProvider(this.prefs) { _loadGoals(); }

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  void _loadGoals() {
    final data = prefs.getString('goals');
    if (data != null) {
      _goals = (jsonDecode(data) as List).map((e) => Goal.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveGoals() {
    prefs.setString('goals', jsonEncode(_goals.map((e) => e.toJson()).toList()));
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    _saveGoals();
    notifyListeners();
  }

  void updateGoal(Goal goal) {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _goals[idx] = goal;
      _saveGoals();
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _saveGoals();
    notifyListeners();
  }

  void updateProgress(String id, double progress) {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _goals[idx].progress = progress.clamp(0.0, 1.0);
      if (_goals[idx].progress >= 1.0) _goals[idx].isCompleted = true;
      _saveGoals();
      notifyListeners();
    }
  }
}
