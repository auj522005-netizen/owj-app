import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class CharacterProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  String _activeCharacter = 'Wesal';
  List<Map<String, String>> _customCharacters = [];

  CharacterProvider(this.prefs) {
    _activeCharacter = prefs.getString('active_character') ?? 'Wesal';
    _loadCustomCharacters();
  }

  String get activeCharacter => _activeCharacter;
  List<Map<String, String>> get customCharacters => _customCharacters;
  List<Map<String, String>> get allCharacters => [...AppConstants.characters, ..._customCharacters];

  void _loadCustomCharacters() {
    // Load custom characters from prefs
    final count = prefs.getInt('custom_char_count') ?? 0;
    _customCharacters = [];
    for (int i = 0; i < count && i < 5; i++) {
      final name = prefs.getString('custom_char_${i}_name') ?? '';
      final emoji = prefs.getString('custom_char_${i}_emoji') ?? '🤖';
      final desc = prefs.getString('custom_char_${i}_desc') ?? '';
      final system = prefs.getString('custom_char_${i}_system') ?? '';
      if (name.isNotEmpty) {
        _customCharacters.add({
          'name': name, 'emoji': emoji, 'desc': desc, 'system': system,
        });
      }
    }
    notifyListeners();
  }

  void setActiveCharacter(String name) {
    _activeCharacter = name;
    prefs.setString('active_character', name);
    notifyListeners();
  }

  void addCustomCharacter(Map<String, String> character) {
    if (_customCharacters.length >= 5) return;
    final idx = _customCharacters.length;
    prefs.setString('custom_char_${idx}_name', character['name'] ?? '');
    prefs.setString('custom_char_${idx}_emoji', character['emoji'] ?? '🤖');
    prefs.setString('custom_char_${idx}_desc', character['desc'] ?? '');
    prefs.setString('custom_char_${idx}_system', character['system'] ?? '');
    prefs.setInt('custom_char_count', idx + 1);
    _loadCustomCharacters();
  }

  void removeCustomCharacter(int index) {
    if (index < 0 || index >= _customCharacters.length) return;
    // Shift remaining characters
    for (int i = index; i < _customCharacters.length - 1; i++) {
      prefs.setString('custom_char_${i}_name', _customCharacters[i + 1]['name'] ?? '');
      prefs.setString('custom_char_${i}_emoji', _customCharacters[i + 1]['emoji'] ?? '🤖');
      prefs.setString('custom_char_${i}_desc', _customCharacters[i + 1]['desc'] ?? '');
      prefs.setString('custom_char_${i}_system', _customCharacters[i + 1]['system'] ?? '');
    }
    prefs.remove('custom_char_${_customCharacters.length - 1}_name');
    prefs.remove('custom_char_${_customCharacters.length - 1}_emoji');
    prefs.remove('custom_char_${_customCharacters.length - 1}_desc');
    prefs.remove('custom_char_${_customCharacters.length - 1}_system');
    prefs.setInt('custom_char_count', _customCharacters.length - 1);
    _loadCustomCharacters();
  }

  String getSystemPrompt() {
    final char = allCharacters.firstWhere(
      (c) => c['name'] == _activeCharacter,
      orElse: () => AppConstants.characters[0],
    );
    return char['system'] ?? '';
  }
}
