import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Habit {
  final String id;
  String name;
  String emoji;
  List<String> completedDates;
  String frequency; // daily, weekly
  String? reminderTime;
  int streak;

  Habit({
    required this.id,
    required this.name,
    this.emoji = '✅',
    this.completedDates = const [],
    this.frequency = 'daily',
    this.reminderTime,
    this.streak = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'emoji': emoji,
    'completedDates': completedDates, 'frequency': frequency,
    'reminderTime': reminderTime, 'streak': streak,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'], name: json['name'], emoji: json['emoji'] ?? '✅',
    completedDates: List<String>.from(json['completedDates'] ?? []),
    frequency: json['frequency'] ?? 'daily',
    reminderTime: json['reminderTime'],
    streak: json['streak'] ?? 0,
  );

  bool isCompletedToday() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return completedDates.contains(today);
  }
}

class HabitsProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<Habit> _habits = [];

  HabitsProvider(this.prefs) { _loadHabits(); }

  List<Habit> get habits => _habits;
  List<Habit> get todayHabits => _habits;

  void _loadHabits() {
    final data = prefs.getString('habits');
    if (data != null) {
      _habits = (jsonDecode(data) as List).map((e) => Habit.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveHabits() {
    prefs.setString('habits', jsonEncode(_habits.map((e) => e.toJson()).toList()));
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _saveHabits();
    notifyListeners();
  }

  void toggleHabitToday(String id) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_habits[idx].completedDates.contains(today)) {
      _habits[idx].completedDates.remove(today);
      _habits[idx].streak = (_habits[idx].streak - 1).clamp(0, 999);
    } else {
      _habits[idx].completedDates.add(today);
      _habits[idx].streak += 1;
    }
    _saveHabits();
    notifyListeners();
  }

  double get todayCompletionRate {
    if (_habits.isEmpty) return 0;
    final completed = _habits.where((h) => h.isCompletedToday()).length;
    return completed / _habits.length;
  }
}
