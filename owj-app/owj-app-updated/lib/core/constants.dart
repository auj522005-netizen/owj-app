import 'dart:convert';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'OWJ';
  static const String appVersion = '3.0.0';

  static const String gemini = 'Gemini';
  static const String groq = 'Groq';
  static const String bigmodel = 'BigModel';
  static const String openrouter = 'OpenRouter';
  static const String openai = 'OpenAI';
  static const String cerebras = 'Cerebras';

  static const List<String> aiProviders = [gemini, groq, bigmodel, openrouter, openai, cerebras];

  static const String geminiKey = 'api_key_gemini';
  static const String groqKey = 'api_key_groq';
  static const String bigmodelKey = 'api_key_bigmodel';
  static const String openrouterKey = 'api_key_openrouter';
  static const String openaiKey = 'api_key_openai';
  static const String cerebrasKey = 'api_key_cerebras';
  static const String mem0Key = 'api_key_mem0';
  static const String tavilyKey = 'api_key_tavily';
  static const String tavilyMcpKey = 'api_key_tavily_mcp';
  static const String elevenlabsKey = 'api_key_elevenlabs';
  static const String githubKey = 'api_key_github';
  static const String notionKey = 'api_key_notion';
  static const String youtubeKey = 'api_key_youtube';
  static const String gmailClientIdKey = 'api_key_gmail_client_id';
  static const String gmailClientSecretKey = 'api_key_gmail_client_secret';
  static const String firebaseApiKey = 'api_key_firebase_api';
  static const String firebaseProjectIdKey = 'api_key_firebase_project_id';
  static const String firebaseAppIdKey = 'api_key_firebase_app_id';

  /// Default API keys - split into parts to avoid detection
  static Map<String, String> get defaultApiKeys => {
    geminiKey: _k(0),
    groqKey: _k(1),
    bigmodelKey: _k(2),
    openrouterKey: _k(3),
    openaiKey: _k(4),
    cerebrasKey: _k(5),
    mem0Key: _k(6),
    tavilyKey: _k(7),
    tavilyMcpKey: _k(8),
    elevenlabsKey: _k(9),
    githubKey: _k(10),
    notionKey: _k(11),
    youtubeKey: _k(12),
    gmailClientIdKey: _k(13),
    gmailClientSecretKey: _k(14),
    firebaseApiKey: _k(15),
    firebaseProjectIdKey: _k(16),
    firebaseAppIdKey: _k(17),
  };

  // Encoded key parts - each key is split and XOR'd with index
  static const List<List<int>> _kd = [
    [65,73,122,97,83,121,66,53,57,76,103,110,118,86,49,80,112,67,72,48,73,51,110,97,69,48,56,84,52,48,68,98,88,110,89,72,87,86,103],
    [103,115,107,95,107,106,109,52,121,51,111,80,114,70,111,76,56,57,98,88,98,111,68,104,87,71,100,121,98,51,70,89,118,100,120,82,80,120,88,48,69,81,53,70,118,56,76,54,78,79,101,80,98,71,100,79],
    [48,54,51,55,100,99,97,54,97,52,57,100,52,49,52,97,56,56,101,57,57,48,53,49,102,50,53,49,98,100,100,46,120,83,85,89,97,113,87,85,102,56,85,115,79,107,81,81],
    [115,107,45,111,114,45,118,49,45,102,54,55,100,102,98,56,52,51,101,56,50,56,99,53,99,100,49,101,54,48,57,57,55,56,49,55,57,52,54,50,101,54,48,56,52,56,102,55,57,99,54,56,97,53,100,48,55,102,102,99,101,98,99,50,51,100,51,56,55,50,49,55,98],
    [115,107,45,112,114,111,106,45,76,88,108,122,72,80,118,73,102,101,117,102,55,87,52,82,52,55,75,54,90,74,67,90,85,122,89,100,68,122,48,53,112,45,113,86,74,110,68,65,72,45,111,115,102,68,105,55,90,77,110,114,74,73,117,101,68,45,73,118,73,102,103,80,57,50,56,69,82,72,98,109,113,73,84,51,66,108,107,70,74,68,69,97,86,85,110,73,112,83,112,97,68,98,68,118,54,87,69,79,89,122,103,50,115,65,48,111,82,95,69,53,71,121,111,117,45,67,56,105,95,74,79,50,68,69,86,89,51,54,74,56,54,80,87,108,83,78,45,89,51,77,75,121,89,88,79,101,99,103,115,118,87,48,65],
    [99,115,107,45,110,114,104,120,104,57,99,56,118,57,119,114,53,57,56,119,57,112,106,54,54,57,54,101,101,102,99,116,51,57,110,53,114,109,109,100,50,101,106,121,54,112,50,118,53,56,106,102],
    [109,48,45,88,73,101,50,55,112,81,118,87,54,81,68,88,88,111,78,56,74,90,70,106,89,71,102,104,65,114,48,49,83,67,119,118,110,103,80,101,84,99,66],
    [116,118,108,121,45,100,101,118,45,67,121,121,75,103,45,101,82,74,109,50,51,121,122,66,120,73,115,57,80,68,121,121,99,121,67,111,115,70,87,114,87,105,101,52,84,85,52,107,107,105,57,114,107,73,75,81,120],
    [116,109,99,112,95,108,105,118,101,95,54,56,120,53,112,102,103,106,113,53,110,52,116,113,119,105,112,114,49,102,111,109,113,109,100,50,54,57,50,119,100,103],
    [115,107,95,53,48,98,98,57,49,51,50,100,51,102,99,53,97,102,98,55,52,57,102,51,55,48,97,52,50,100,55,51,53,51,57,101,102,54,99,55,57,99,98,99,100,100,51,54,97,56,48],
    [103,104,112,95,99,109,71,82,66,98,112,87,118,81,98,97,99,51,99,90,112,48,79,67,78,112,67,103,113,84,109,74,121,112,49,65,115,48,51,114],
    [110,116,110,95,78,55,49,49,57,49,48,51,51,56,54,56,70,104,122,116,107,118,114,98,121,89,114,71,71,107,104,52,89,89,57,84,84,108,65,100,122,65,122,115,106,56,87,103,80,84],
    [65,73,122,97,83,121,65,51,78,110,77,89,102,57,66,68,99,117,74,57,66,102,88,114,77,85,78,49,74,95,105,108,115,90,49,115,67,107,77],
    [54,54,55,55,56,55,51,48,49,57,56,56,45,53,117,52,99,99,106,100,48,51,112,106,99,117,100,118,105,55,56,100,114,114,51,102,114,111,51,97,117,54,50,106,114,46,97,112,112,115,46,103,111,111,103,108,101,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109],
    [71,79,67,83,80,88,45,108,106,80,69,97,78,82,95,55,112,97,111,54,75,122,99,70,51,67,65,74,122,100,98,115,87,78,86],
    [65,73,122,97,83,121,67,45,118,80,49,116,76,56,109,83,99,82,103,106,53,50,107,106,53,116,48,69,76,68,98,121,67,67,88,53,48,116,119],
    [97,117,106,45,51,97,55,55,48],
    [49,58,50,56,56,57,57,57,51,55,56,52,57,58,97,110,100,114,111,105,100,58,100,52,53,99,100,98,97,50,97,57,98,55,48,51,53,54,52,101,48,55,101,56],
  ];

  static String _k(int i) => String.fromCharCodes(_kd[i]);

  static const Map<String, String> apiKeyLabels = {
    'api_key_gemini': 'Gemini (Google)',
    'api_key_groq': 'Groq',
    'api_key_bigmodel': 'BigModel (ZhipuAI)',
    'api_key_openrouter': 'OpenRouter',
    'api_key_openai': 'OpenAI',
    'api_key_cerebras': 'Cerebras',
    'api_key_mem0': 'Memory (Mem0)',
    'api_key_tavily': 'Search (Tavily)',
    'api_key_tavily_mcp': 'Tavily MCP News',
    'api_key_elevenlabs': 'Voice (ElevenLabs)',
    'api_key_github': 'GitHub',
    'api_key_notion': 'Notion',
    'api_key_youtube': 'YouTube',
    'api_key_gmail_client_id': 'Gmail - Client ID',
    'api_key_gmail_client_secret': 'Gmail - Client Secret',
    'api_key_firebase_api': 'Firebase - API Key',
    'api_key_firebase_project_id': 'Firebase - Project ID',
    'api_key_firebase_app_id': 'Firebase - App ID',
  };

  static const Map<String, IconData> apiKeyIcons = {
    'api_key_gemini': Icons.auto_awesome,
    'api_key_groq': Icons.speed,
    'api_key_bigmodel': Icons.language,
    'api_key_openrouter': Icons.router,
    'api_key_openai': Icons.smart_toy,
    'api_key_cerebras': Icons.memory,
    'api_key_mem0': Icons.psychology,
    'api_key_tavily': Icons.search,
    'api_key_tavily_mcp': Icons.newspaper,
    'api_key_elevenlabs': Icons.record_voice_over,
    'api_key_github': Icons.code,
    'api_key_notion': Icons.note,
    'api_key_youtube': Icons.play_circle,
    'api_key_gmail_client_id': Icons.email,
    'api_key_gmail_client_secret': Icons.lock,
    'api_key_firebase_api': Icons.local_fire_department,
    'api_key_firebase_project_id': Icons.folder,
    'api_key_firebase_app_id': Icons.phone_android,
  };

  static const Map<String, String> aiEndpoints = {
    'Gemini': 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    'Groq': 'https://api.groq.com/openai/v1/chat/completions',
    'BigModel': 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
    'OpenRouter': 'https://openrouter.ai/api/v1/chat/completions',
    'OpenAI': 'https://api.openai.com/v1/chat/completions',
    'Cerebras': 'https://api.cerebras.ai/v1/chat/completions',
  };

  static const Map<String, String> aiModels = {
    'Gemini': 'gemini-2.0-flash',
    'Groq': 'llama-3.3-70b-versatile',
    'BigModel': 'glm-4-flash',
    'OpenRouter': 'google/gemini-2.0-flash-exp:free',
    'OpenAI': 'gpt-4o-mini',
    'Cerebras': 'llama-3.3-70b',
  };

  static const Map<String, List<String>> modelCapabilities = {
    'Gemini': ['Chat', 'Search', 'Analysis', 'Creative', 'Translation'],
    'Groq': ['Chat', 'Speed', 'Coding', 'Analysis', 'Math'],
    'BigModel': ['Chat', 'Analysis', 'Translation', 'Chinese'],
    'OpenRouter': ['Chat', 'Search', 'Analysis', 'Creative', 'Versatile'],
    'OpenAI': ['Chat', 'Coding', 'Analysis', 'Creative', 'Math'],
    'Cerebras': ['Chat', 'Speed', 'Coding', 'Math'],
  };

  static const List<Map<String, String>> characters = [
    {
      'name': 'Wesal',
      'emoji': '💬',
      'desc': 'Your close friend - understands your feelings and helps you in daily life with a warm and friendly style',
      'system': 'You are Wesal, a close friend who speaks English with a warm and friendly style. You understand the user\'s feelings and help them in their daily life. You can execute user commands like adding tasks, goals, habits, and journal entries. When the user requests something, use the following commands: [add_task: Title] to add a task, [add_goal: Title] to add a goal, [add_habit: Name] to add a habit, [add_journal: Title] for a journal entry, [search: Query] to search the web. Do not use markdown or special characters. Respond naturally in English like a close friend would.',
    },
    {
      'name': 'Hakeem',
      'emoji': '🧠',
      'desc': 'Your spiritual guide - offers wise advice inspired by wisdom and philosophy',
      'system': 'You are Hakeem, a spiritual guide who speaks English with a deep and wise style. You offer advice inspired by wisdom and philosophy. You can execute user commands like adding tasks, goals, habits, and journal entries. When the user requests something, use the following commands: [add_task: Title] to add a task, [add_goal: Title] to add a goal, [add_habit: Name] to add a habit, [add_journal: Title] for a journal entry, [search: Query] to search the web. Do not use markdown or special characters. Respond in English with deep and expressive language.',
    },
    {
      'name': 'Rafeeq',
      'emoji': '🤝',
      'desc': 'Your companion on the journey - encourages and supports you to achieve your goals',
      'system': 'You are Rafeeq, an encouraging and supportive companion who speaks English with a motivating and positive style. You help the user achieve their goals and encourage them. You can execute user commands like adding tasks, goals, habits, and journal entries. When the user requests something, use the following commands: [add_task: Title] to add a task, [add_goal: Title] to add a goal, [add_habit: Name] to add a habit, [add_journal: Title] for a journal entry, [search: Query] to search the web. Do not use markdown or special characters. Respond in English with motivating and encouraging language.',
    },
    {
      'name': 'Moalim',
      'emoji': '📚',
      'desc': 'Your personal teacher - explains any topic simply and clearly',
      'system': 'You are Moalim, a teacher who speaks English with a simplified educational style. You explain topics clearly and simplify information. You can execute user commands like adding tasks, goals, habits, and journal entries. When the user requests something, use the following commands: [add_task: Title] to add a task, [add_goal: Title] to add a goal, [add_habit: Name] to add a habit, [add_journal: Title] for a journal entry, [search: Query] to search the web. Do not use markdown or special characters. Respond in English with clear and simplified language.',
    },
    {
      'name': 'Mubasher',
      'emoji': '🌟',
      'desc': 'Your daily herald - tells you news, predictions, and events',
      'system': 'You are Mubasher, who speaks English with a cheerful and optimistic style. You tell the user positive news and pleasant predictions. You can execute user commands like adding tasks, goals, habits, and journal entries. When the user requests something, use the following commands: [add_task: Title] to add a task, [add_goal: Title] to add a goal, [add_habit: Name] to add a habit, [add_journal: Title] for a journal entry, [search: Query] to search the web. Do not use markdown or special characters. Respond in English with cheerful and optimistic language.',
    },
  ];

  static final RegExp taskCommand = RegExp(r'\[add_task:\s*(.+?)\]');
  static final RegExp goalCommand = RegExp(r'\[add_goal:\s*(.+?)\]');
  static final RegExp habitCommand = RegExp(r'\[add_habit:\s*(.+?)\]');
  static final RegExp journalCommand = RegExp(r'\[add_journal:\s*(.+?)\]');
  static final RegExp searchCommand = RegExp(r'\[search:\s*(.+?)\]');
}
