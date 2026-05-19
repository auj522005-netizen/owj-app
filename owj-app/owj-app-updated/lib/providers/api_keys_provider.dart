import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiKeysProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  Map<String, String> _keys = {};
  Map<String, bool> _keyStatus = {};
  String _selectedModel = 'Gemini';

  ApiKeysProvider(this.prefs) {
    _initDefaults();
    _loadKeys();
    _selectedModel = prefs.getString('selected_model') ?? 'Gemini';
  }

  Map<String, String> get keys => _keys;
  Map<String, bool> get keyStatus => _keyStatus;
  String get selectedModel => _selectedModel;

  /// Pre-populate default API keys on first launch
  void _initDefaults() {
    final isFirstLaunch = prefs.getBool('keys_initialized_v3') ?? false;
    if (!isFirstLaunch) {
      for (var entry in AppConstants.defaultApiKeys.entries) {
        final existing = prefs.getString(entry.key);
        if (existing == null || existing.isEmpty) {
          prefs.setString(entry.key, entry.value);
        }
      }
      prefs.setBool('keys_initialized_v3', true);
    }
  }

  void _loadKeys() {
    for (var key in AppConstants.apiKeyLabels.keys) {
      _keys[key] = prefs.getString(key) ?? '';
      _keyStatus[key] = _keys[key]!.isNotEmpty;
    }
    notifyListeners();
  }

  String getKey(String storageKey) => _keys[storageKey] ?? '';

  bool isKeyActive(String storageKey) => _keyStatus[storageKey] ?? false;

  void setKey(String storageKey, String value) {
    _keys[storageKey] = value;
    prefs.setString(storageKey, value);
    _keyStatus[storageKey] = value.isNotEmpty;
    notifyListeners();
  }

  void removeKey(String storageKey) {
    _keys[storageKey] = '';
    prefs.remove(storageKey);
    _keyStatus[storageKey] = false;
    notifyListeners();
  }

  void resetToDefaults() {
    for (var entry in AppConstants.defaultApiKeys.entries) {
      prefs.setString(entry.key, entry.value);
    }
    _loadKeys();
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    prefs.setString('selected_model', model);
    notifyListeners();
  }

  void markKeyFailed(String storageKey) {
    _keyStatus[storageKey] = false;
    notifyListeners();
  }

  void markKeyActive(String storageKey) {
    _keyStatus[storageKey] = true;
    notifyListeners();
  }

  int get activeKeyCount => _keyStatus.values.where((v) => v).length;
  int get totalKeyCount => _keyStatus.length;

  // Get active AI provider keys in order
  List<MapEntry<String, String>> getActiveAIKeys() {
    const aiKeyOrder = [
      AppConstants.geminiKey, AppConstants.groqKey, AppConstants.bigmodelKey,
      AppConstants.openrouterKey, AppConstants.openaiKey, AppConstants.cerebrasKey,
    ];
    return aiKeyOrder
      .where((k) => (_keys[k] ?? '').isNotEmpty)
      .map((k) => MapEntry(k, _keys[k]!))
      .toList();
  }

  // Get the API key for the selected model
  String getSelectedModelKey() {
    switch (_selectedModel) {
      case 'Gemini': return _keys[AppConstants.geminiKey] ?? '';
      case 'Groq': return _keys[AppConstants.groqKey] ?? '';
      case 'BigModel': return _keys[AppConstants.bigmodelKey] ?? '';
      case 'OpenRouter': return _keys[AppConstants.openrouterKey] ?? '';
      case 'OpenAI': return _keys[AppConstants.openaiKey] ?? '';
      case 'Cerebras': return _keys[AppConstants.cerebrasKey] ?? '';
      default: return '';
    }
  }

  String getSelectedModelStorageKey() {
    switch (_selectedModel) {
      case 'Gemini': return AppConstants.geminiKey;
      case 'Groq': return AppConstants.groqKey;
      case 'BigModel': return AppConstants.bigmodelKey;
      case 'OpenRouter': return AppConstants.openrouterKey;
      case 'OpenAI': return AppConstants.openaiKey;
      case 'Cerebras': return AppConstants.cerebrasKey;
      default: return AppConstants.geminiKey;
    }
  }

  // Get active provider name (first with key)
  String? getActiveProvider() {
    for (var provider in AppConstants.aiProviders) {
      final key = _getStorageKeyForProvider(provider);
      if ((_keys[key] ?? '').isNotEmpty) return provider;
    }
    return null;
  }

  String _getStorageKeyForProvider(String provider) {
    switch (provider) {
      case 'Gemini': return AppConstants.geminiKey;
      case 'Groq': return AppConstants.groqKey;
      case 'BigModel': return AppConstants.bigmodelKey;
      case 'OpenRouter': return AppConstants.openrouterKey;
      case 'OpenAI': return AppConstants.openaiKey;
      case 'Cerebras': return AppConstants.cerebrasKey;
      default: return AppConstants.geminiKey;
    }
  }
}
