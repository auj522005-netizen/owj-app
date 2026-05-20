import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import 'api_keys_provider.dart';
import 'tasks_provider.dart';
import 'goals_provider.dart';
import 'habits_provider.dart';
import 'journal_provider.dart';
import 'notification_provider.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? character;
  final String? provider;
  final bool isToolResult;
  final String? toolType;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.character,
    this.provider,
    this.isToolResult = false,
    this.toolType,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'isUser': isUser,
    'timestamp': timestamp.toIso8601String(), 'character': character,
    'provider': provider, 'isToolResult': isToolResult, 'toolType': toolType,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'], content: json['content'], isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']), character: json['character'],
    provider: json['provider'],
    isToolResult: json['isToolResult'] ?? false, toolType: json['toolType'],
  );
}

class ToolResult {
  final String type;
  final String title;
  final bool success;
  ToolResult({required this.type, required this.title, required this.success});
}

class ChatProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentCharacter = 'Wesal';
  String _activeProvider = '';
  String _errorMessage = '';
  List<ToolResult> _toolResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // References to other providers (set after initialization)
  TasksProvider? _tasksProvider;
  GoalsProvider? _goalsProvider;
  HabitsProvider? _habitsProvider;
  JournalProvider? _journalProvider;
  NotificationProvider? _notificationProvider;

  ChatProvider(this.prefs) {
    _loadMessages();
  }

  void setProviders({
    required TasksProvider tasks,
    required GoalsProvider goals,
    required HabitsProvider habits,
    required JournalProvider journal,
    NotificationProvider? notifications,
  }) {
    _tasksProvider = tasks;
    _goalsProvider = goals;
    _habitsProvider = habits;
    _journalProvider = journal;
    _notificationProvider = notifications;
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get currentCharacter => _currentCharacter;
  String get activeProvider => _activeProvider;
  String get errorMessage => _errorMessage;
  List<ToolResult> get toolResults => _toolResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  void _loadMessages() {
    final data = prefs.getString('chat_messages');
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _messages = jsonList.map((e) => ChatMessage.fromJson(e)).toList();
      } catch (_) {
        _messages = [];
      }
    }
    _currentCharacter = prefs.getString('active_character') ?? 'Wesal';
    notifyListeners();
  }

  void _saveMessages() {
    // Keep only last 100 messages to avoid storage overflow
    final toSave = _messages.length > 100
      ? _messages.sublist(_messages.length - 100)
      : _messages;
    final data = jsonEncode(toSave.map((e) => e.toJson()).toList());
    prefs.setString('chat_messages', data);
  }

  void setCharacter(String character) {
    _currentCharacter = character;
    prefs.setString('active_character', character);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _toolResults.clear();
    _saveMessages();
    notifyListeners();
  }

  String _getSystemPrompt() {
    final char = AppConstants.characters.firstWhere(
      (c) => c['name'] == _currentCharacter,
      orElse: () => AppConstants.characters[0],
    );
    return char['system'] ?? '';
  }

  String _cleanAIResponse(String text) {
    // Remove thinking blocks
    text = text.replaceAll(RegExp(r'<think[\s\S]*?</think?>'), '');
    text = text.replaceAll(RegExp(r'<thinking[\s\S]*?</thinking>'), '');
    // Remove markdown headers
    text = text.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    // Remove bold/italic markers
    text = text.replaceAll(RegExp(r'\*{1,3}'), '');
    text = text.replaceAll(RegExp(r'_{1,3}'), '');
    // Remove code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAll(RegExp(r'`[^`]+`'), '');
    // Remove links but keep text
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    // Remove list markers
    text = text.replaceAll(RegExp(r'^\s*[-*+]\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s*', multiLine: true), '');
    // Remove HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    // Clean extra whitespace
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.trim();
    return text;
  }

  /// Parse AI response for tool commands and execute them
  List<ToolResult> _parseAndExecuteTools(String response) {
    List<ToolResult> results = [];

    // Parse task commands
    for (var match in AppConstants.taskCommand.allMatches(response)) {
      final title = match.group(1)?.trim() ?? '';
      if (title.isNotEmpty && _tasksProvider != null) {
        _tasksProvider!.addTask(Task(
          id: const Uuid().v4(),
          title: title,
          dueDate: DateTime.now(),
          priority: 'medium',
        ));
        results.add(ToolResult(type: 'Task', title: title, success: true));
        _notificationProvider?.notifyAIAction('Task', title);
      }
    }

    // Parse goal commands
    for (var match in AppConstants.goalCommand.allMatches(response)) {
      final title = match.group(1)?.trim() ?? '';
      if (title.isNotEmpty && _goalsProvider != null) {
        _goalsProvider!.addGoal(Goal(
          id: const Uuid().v4(),
          title: title,
          deadline: DateTime.now().add(const Duration(days: 30)),
        ));
        results.add(ToolResult(type: 'Goal', title: title, success: true));
        _notificationProvider?.notifyAIAction('Goal', title);
      }
    }

    // Parse habit commands
    for (var match in AppConstants.habitCommand.allMatches(response)) {
      final name = match.group(1)?.trim() ?? '';
      if (name.isNotEmpty && _habitsProvider != null) {
        _habitsProvider!.addHabit(Habit(
          id: const Uuid().v4(),
          name: name,
        ));
        results.add(ToolResult(type: 'Habit', title: name, success: true));
        _notificationProvider?.notifyAIAction('Habit', name);
      }
    }

    // Parse journal commands
    for (var match in AppConstants.journalCommand.allMatches(response)) {
      final title = match.group(1)?.trim() ?? '';
      if (title.isNotEmpty && _journalProvider != null) {
        _journalProvider!.addEntry(JournalEntry(
          id: const Uuid().v4(),
          title: title,
          content: 'Created from chat',
          date: DateTime.now(),
        ));
        results.add(ToolResult(type: 'Journal', title: title, success: true));
        _notificationProvider?.notifyAIAction('Journal', title);
      }
    }

    return results;
  }

  Future<String> _searchWeb(String query, ApiKeysProvider apiKeys) async {
    final tavilyKey = apiKeys.getKey(AppConstants.tavilyKey);
    if (tavilyKey.isEmpty) return 'No search key available';

    _isSearching = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.tavily.com/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': tavilyKey,
          'query': query,
          'max_results': 5,
          'include_answer': true,
        }),
      );

      _isSearching = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? '';
        if (answer.isNotEmpty) return answer;

        final results = data['results'] as List? ?? [];
        if (results.isEmpty) return 'No results found';

        return results.map((r) => r['content'] ?? '').where((c) => c.isNotEmpty).take(3).join('\n\n');
      }
      return 'Search error';
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      return 'Search error: ${e.toString()}';
    }
  }

  Future<void> sendMessage(String content, ApiKeysProvider apiKeys) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      character: _currentCharacter,
    );
    _messages.add(userMsg);
    _isLoading = true;
    _errorMessage = '';
    _toolResults.clear();
    notifyListeners();

    try {
      // Check if user is requesting a search
      String messageToSend = content;
      final searchMatch = AppConstants.searchCommand.firstMatch(content);
      if (searchMatch != null) {
        final query = searchMatch.group(1)?.trim() ?? content;
        final searchResults = await _searchWeb(query, apiKeys);
        messageToSend = 'User asked: $content\n\nSearch results:\n$searchResults\n\nAnswer based on these search results in English.';
      }

      final response = await _callAI(messageToSend, apiKeys);
      final cleaned = _cleanAIResponse(response);

      // Parse and execute tool commands
      final toolResults = _parseAndExecuteTools(response);
      _toolResults = toolResults;

      // Remove command tags from display text
      var displayText = cleaned;
      displayText = AppConstants.taskCommand.allMatches(displayText).fold(displayText,
        (text, match) => text.replaceAll(match.group(0)!, ''));
      displayText = AppConstants.goalCommand.allMatches(displayText).fold(displayText,
        (text, match) => text.replaceAll(match.group(0)!, ''));
      displayText = AppConstants.habitCommand.allMatches(displayText).fold(displayText,
        (text, match) => text.replaceAll(match.group(0)!, ''));
      displayText = AppConstants.journalCommand.allMatches(displayText).fold(displayText,
        (text, match) => text.replaceAll(match.group(0)!, ''));
      displayText = AppConstants.searchCommand.allMatches(displayText).fold(displayText,
        (text, match) => text.replaceAll(match.group(0)!, ''));
      displayText = displayText.trim();

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: displayText.isEmpty ? 'Done!' : displayText,
        isUser: false,
        timestamp: DateTime.now(),
        character: _currentCharacter,
        provider: _activeProvider,
      );
      _messages.add(aiMsg);
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
        character: _currentCharacter,
      );
      _messages.add(errorMsg);
    }

    _isLoading = false;
    _saveMessages();
    notifyListeners();
  }

  /// Call AI using selected model first, then fallback to others
  Future<String> _callAI(String message, ApiKeysProvider apiKeys) async {
    final selectedModel = apiKeys.selectedModel;
    final selectedKey = apiKeys.getSelectedModelKey();

    // Try selected model first
    if (selectedKey.isNotEmpty) {
      try {
        _activeProvider = selectedModel;
        notifyListeners();

        if (selectedModel == 'Gemini') {
          return await _callGemini(selectedKey, message);
        } else {
          return await _callOpenAICompatible(
            AppConstants.aiEndpoints[selectedModel]!,
            selectedKey,
            AppConstants.aiModels[selectedModel]!,
            message,
          );
        }
      } catch (e) {
        // Selected model failed, try others
      }
    }

    // Fallback to other providers
    final providers = [
      {'name': 'Groq', 'key': AppConstants.groqKey, 'type': 'openai'},
      {'name': 'BigModel', 'key': AppConstants.bigmodelKey, 'type': 'openai'},
      {'name': 'OpenRouter', 'key': AppConstants.openrouterKey, 'type': 'openai'},
      {'name': 'OpenAI', 'key': AppConstants.openaiKey, 'type': 'openai'},
      {'name': 'Cerebras', 'key': AppConstants.cerebrasKey, 'type': 'openai'},
      {'name': 'Gemini', 'key': AppConstants.geminiKey, 'type': 'gemini'},
    ];

    for (var provider in providers) {
      // Skip if it's the same as the selected model that already failed
      if (provider['name'] == selectedModel) continue;

      final apiKey = apiKeys.getKey(provider['key'] as String);
      if (apiKey.isEmpty) continue;

      try {
        _activeProvider = provider['name'] as String;
        notifyListeners();

        if (provider['type'] == 'gemini') {
          return await _callGemini(apiKey, message);
        } else {
          return await _callOpenAICompatible(
            AppConstants.aiEndpoints[provider['name']]!,
            apiKey,
            AppConstants.aiModels[provider['name']]!,
            message,
          );
        }
      } catch (e) {
        apiKeys.markKeyFailed(provider['key'] as String);
        continue;
      }
    }

    throw Exception('No working API key. Go to Settings and configure your keys.');
  }

  /// Multi-model parallel call for different task types
  Future<Map<String, String>> callMultipleModels(
    String message, ApiKeysProvider apiKeys, List<String> models
  ) async {
    final results = <String, String>{};
    final futures = <Future<void>>[];

    for (var model in models) {
      final apiKey = apiKeys.getKey(
        model == 'Gemini' ? AppConstants.geminiKey :
        model == 'Groq' ? AppConstants.groqKey :
        model == 'BigModel' ? AppConstants.bigmodelKey :
        model == 'OpenRouter' ? AppConstants.openrouterKey :
        model == 'OpenAI' ? AppConstants.openaiKey :
        AppConstants.cerebrasKey
      );

      if (apiKey.isEmpty) continue;

      futures.add(() async {
        try {
          String response;
          if (model == 'Gemini') {
            response = await _callGemini(apiKey, message);
          } else {
            response = await _callOpenAICompatible(
              AppConstants.aiEndpoints[model]!,
              apiKey,
              AppConstants.aiModels[model]!,
              message,
            );
          }
          results[model] = _cleanAIResponse(response);
        } catch (e) {
          results[model] = 'Failed: ${e.toString()}';
        }
      }());
    }

    await Future.wait(futures);
    return results;
  }

  Future<String> _callGemini(String apiKey, String message) async {
    final url = '${AppConstants.aiEndpoints['Gemini']}?key=$apiKey';
    final systemPrompt = _getSystemPrompt();

    final recentMessages = _messages.length > 10
      ? _messages.sublist(_messages.length - 10)
      : _messages;
    final conversationHistory = recentMessages.map((m) {
      return {'role': m.isUser ? 'user' : 'model', 'parts': [{'text': m.content}]};
    }).toList();

    conversationHistory.insert(0, {
      'role': 'user',
      'parts': [{'text': 'System instructions: $systemPrompt\n\nUser message: $message'}]
    });

    if (conversationHistory.length > 1) {
      conversationHistory.add({
        'role': 'user',
        'parts': [{'text': message}]
      });
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': conversationHistory,
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 4096,
        }
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]['content']['parts'][0]['text'] ?? 'No response';
    } else {
      throw Exception('Gemini error: ${response.statusCode}');
    }
  }

  Future<String> _callOpenAICompatible(
    String endpoint, String apiKey, String model, String message
  ) async {
    final systemPrompt = _getSystemPrompt();

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    final recentMsgs = _messages.length > 10
      ? _messages.sublist(_messages.length - 10)
      : _messages;
    for (var msg in recentMsgs) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    messages.add({'role': 'user', 'content': message});

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': 0.8,
        'max_tokens': 4096,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? 'No response';
    } else {
      throw Exception('$model error: ${response.statusCode}');
    }
  }
}
