import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/journal_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => JournalScreenState();
}

class JournalScreenState extends State<JournalScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = 'عادي';

  final List<Map<String, String>> _moods = [
    {'label': 'سعيد', 'emoji': '😊'},
    {'label': 'حزين', 'emoji': '😢'},
    {'label': 'عادي', 'emoji': '😐'},
    {'label': 'متحمس', 'emoji': '🤩'},
    {'label': 'قلق', 'emoji': '😟'},
    {'label': 'هادي', 'emoji': '😌'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, size: 64, color: subColor),
                const SizedBox(height: 16),
                Text('مفيش مذكرات لسه', style: TextStyle(color: subColor, fontSize: 16)),
                const SizedBox(height: 8),
                Text('سجل أول مذكرة ليك', style: TextStyle(color: subColor, fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.entries.length,
          itemBuilder: (context, index) => _buildEntryCard(provider.entries[index], provider, isDark),
        );
      },
    );
  }

  Widget _buildEntryCard(JournalEntry entry, JournalProvider provider, bool isDark) {
    final moodEmoji = _moods.firstWhere((m) => m['label'] == entry.mood, orElse: () => {'emoji': '📝'})['emoji']!;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12), color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            Expanded(child: Text(entry.title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl)),
            Text(moodEmoji, style: const TextStyle(fontSize: 24)),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => provider.deleteEntry(entry.id)),
          ]),
          const SizedBox(height: 8),
          Text(entry.content, style: TextStyle(color: subColor, fontSize: 14, height: 1.6), textDirection: TextDirection.rtl, maxLines: 5, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text('${entry.date.day}/${entry.date.month}/${entry.date.year} - ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}', style: TextStyle(color: subColor, fontSize: 11)),
        ]),
      ),
    );
  }

  void showAddEntryDialog(BuildContext context, bool isDark) {
    _titleController.clear();
    _contentController.clear();
    _mood = 'عادي';
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('مذكرة جديدة', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _moods.map((m) => GestureDetector(
                  onTap: () => setModalState(() => _mood = m['label']!),
                  child: Column(children: [
                    Text(m['emoji']!, style: TextStyle(fontSize: _mood == m['label'] ? 32 : 24)),
                    const SizedBox(height: 2),
                    Text(m['label']!, style: TextStyle(color: _mood == m['label'] ? AppColors.gold : hintColor, fontSize: 10, fontWeight: _mood == m['label'] ? FontWeight.bold : FontWeight.normal)),
                  ]),
                )).toList()),
                const SizedBox(height: 16),
                TextField(controller: _titleController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), decoration: InputDecoration(hintText: 'عنوان المذكرة', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                TextField(controller: _contentController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), maxLines: 6, decoration: InputDecoration(hintText: 'اكتب مذكرة اليوم...', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (_contentController.text.trim().isEmpty) return;
                    Provider.of<JournalProvider>(context, listen: false).addEntry(JournalEntry(
                      id: const Uuid().v4(),
                      title: _titleController.text.trim().isEmpty ? 'مذكرة' : _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      mood: _mood,
                      date: DateTime.now(),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ المذكرة'),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
