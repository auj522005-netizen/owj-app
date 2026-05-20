import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  final String id;
  String title;
  String content;
  String mood; // Happy, Sad, Normal, Excited, Anxious
  DateTime date;
  List<String> tags;

  JournalEntry({
    required this.id,
    required this.title,
    this.content = '',
    this.mood = 'Normal',
    required this.date,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content,
    'mood': mood, 'date': date.toIso8601String(), 'tags': tags,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'], title: json['title'], content: json['content'] ?? '',
    mood: json['mood'] ?? 'Normal', date: DateTime.parse(json['date']),
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class JournalProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<JournalEntry> _entries = [];

  JournalProvider(this.prefs) { _loadEntries(); }

  List<JournalEntry> get entries => _entries;
  List<JournalEntry> get todayEntries => _entries.where((e) {
    final now = DateTime.now();
    return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
  }).toList();

  void _loadEntries() {
    final data = prefs.getString('journal_entries');
    if (data != null) {
      _entries = (jsonDecode(data) as List).map((e) => JournalEntry.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveEntries() {
    prefs.setString('journal_entries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void addEntry(JournalEntry entry) {
    _entries.insert(0, entry);
    _saveEntries();
    notifyListeners();
  }

  void updateEntry(JournalEntry entry) {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) { _entries[idx] = entry; _saveEntries(); notifyListeners(); }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveEntries();
    notifyListeners();
  }
}
