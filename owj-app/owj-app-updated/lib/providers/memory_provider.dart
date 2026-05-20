import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_keys_provider.dart';
import '../core/constants.dart';

class MemoryItem {
  final String id;
  String content;
  String category; // شخصي، عمل، تعلم، صحي، مالي
  DateTime createdAt;
  List<String> tags;

  MemoryItem({
    required this.id,
    required this.content,
    this.category = 'شخصي',
    required this.createdAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'category': category,
    'createdAt': createdAt.toIso8601String(), 'tags': tags,
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
    id: json['id'], content: json['content'],
    category: json['category'] ?? 'شخصي',
    createdAt: DateTime.parse(json['createdAt']),
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class MemoryProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<MemoryItem> _memories = [];
  bool _isSyncing = false;

  MemoryProvider(this.prefs) { _loadMemories(); }

  List<MemoryItem> get memories => _memories;
  bool get isSyncing => _isSyncing;

  void _loadMemories() {
    final data = prefs.getString('memories');
    if (data != null) {
      _memories = (jsonDecode(data) as List).map((e) => MemoryItem.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void _saveMemories() {
    prefs.setString('memories', jsonEncode(_memories.map((e) => e.toJson()).toList()));
  }

  void addMemory(MemoryItem memory) {
    _memories.insert(0, memory);
    _saveMemories();
    notifyListeners();
    _syncToMem0(memory);
  }

  void deleteMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
    _saveMemories();
    notifyListeners();
  }

  List<MemoryItem> searchMemories(String query) {
    return _memories.where((m) =>
      m.content.contains(query) ||
      m.category.contains(query) ||
      m.tags.any((t) => t.contains(query))
    ).toList();
  }

  List<MemoryItem> getByCategory(String category) {
    return _memories.where((m) => m.category == category).toList();
  }

  Future<void> _syncToMem0(MemoryItem memory) async {
    final mem0Key = prefs.getString(AppConstants.mem0Key) ?? '';
    if (mem0Key.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await http.post(
        Uri.parse('https://api.mem0.ai/v1/memories/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $mem0Key',
        },
        body: jsonEncode({
          'messages': [{'role': 'user', 'content': memory.content}],
          'user_id': 'owj_user',
          'metadata': {'category': memory.category, 'tags': memory.tags},
        }),
      );
    } catch (_) {}

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> syncFromMem0(ApiKeysProvider apiKeys) async {
    final mem0Key = apiKeys.getKey(AppConstants.mem0Key);
    if (mem0Key.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.mem0.ai/v1/memories/?user_id=owj_user'),
        headers: {'Authorization': 'Token $mem0Key'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        for (var item in results) {
          final content = item['memory'] ?? '';
          if (content.isNotEmpty && !_memories.any((m) => m.content == content)) {
            _memories.add(MemoryItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: content,
              category: item['metadata']?['category'] ?? 'شخصي',
              createdAt: DateTime.now(),
              tags: List<String>.from(item['metadata']?['tags'] ?? []),
            ));
          }
        }
        _saveMemories();
      }
    } catch (_) {}

    _isSyncing = false;
    notifyListeners();
  }
}
