import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/memory_provider.dart';
import '../providers/api_keys_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => MemoryScreenState();
}

class MemoryScreenState extends State<MemoryScreen> {
  final _contentController = TextEditingController();
  final _searchController = TextEditingController();
  String _category = 'شخصي';
  final _tagController = TextEditingController();
  bool _isSearching = false;
  List<MemoryItem> _searchResults = [];

  final List<String> _categories = ['شخصي', 'عمل', 'تعلم', 'صحي', 'مالي', 'اجتماعي'];

  bool get isSearching => _isSearching;

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  void syncMemory(BuildContext context) {
    final apiKeys = Provider.of<ApiKeysProvider>(context, listen: false);
    Provider.of<MemoryProvider>(context, listen: false).syncFromMem0(apiKeys);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _searchController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Consumer<MemoryProvider>(
      builder: (context, provider, _) {
        return Column(children: [
          if (provider.isSyncing) LinearProgressIndicator(backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder, color: AppColors.gold),
          if (_isSearching) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController, textDirection: TextDirection.rtl,
                style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
                decoration: InputDecoration(hintText: 'ابحث في الذاكرة...', hintStyle: TextStyle(color: subColor), filled: true, fillColor: isDark ? AppColors.darkCard : AppColors.lightCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.search, color: AppColors.gold)),
                onChanged: (query) => setState(() => _searchResults = query.isEmpty ? [] : provider.searchMemories(query)),
              ),
            ),
          ],
          Container(
            height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(scrollDirection: Axis.horizontal, reverse: true, children: _categories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(label: Text(cat), selected: _category == cat, selectedColor: AppColors.gold, labelStyle: TextStyle(color: _category == cat ? AppColors.darkBg : subColor, fontSize: 12), onSelected: (_) => setState(() => _category = cat)),
            )).toList()),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildMemoryList(provider, isDark)),
        ]);
      },
    );
  }

  Widget _buildMemoryList(MemoryProvider provider, bool isDark) {
    final items = _isSearching && _searchResults.isNotEmpty ? _searchResults : _category != 'شخصي' || _isSearching ? provider.getByCategory(_category) : provider.memories;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.psychology, size: 64, color: subColor),
        const SizedBox(height: 16),
        Text('مفيش ذكريات لسه', style: TextStyle(color: subColor, fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final memory = items[index];
        return Card(margin: const EdgeInsets.only(bottom: 10), color: cardColor, child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              Expanded(child: Text(memory.content, style: TextStyle(color: textColor, fontSize: 14, height: 1.5), textDirection: TextDirection.rtl, maxLines: 3, overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18), onPressed: () => provider.deleteMemory(memory.id)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(memory.category, style: TextStyle(color: AppColors.gold, fontSize: 10))),
              const SizedBox(width: 8),
              Text('${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}', style: TextStyle(color: subColor, fontSize: 10)),
              ...memory.tags.map((tag) => Padding(padding: const EdgeInsets.only(right: 4), child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text('#$tag', style: TextStyle(color: AppColors.info, fontSize: 9))))),
            ]),
          ]),
        ));
      },
    );
  }

  void showAddMemoryDialog(BuildContext context, bool isDark) {
    _contentController.clear();
    _tagController.clear();
    List<String> tags = [];
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
                Text('إضافة ذكرى', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(spacing: 6, runSpacing: 6, children: _categories.map((cat) => ChoiceChip(label: Text(cat, style: TextStyle(fontSize: 12)), selected: _category == cat, selectedColor: AppColors.gold, labelStyle: TextStyle(color: _category == cat ? AppColors.darkBg : hintColor), onSelected: (_) => setModalState(() => _category = cat))).toList()),
                const SizedBox(height: 12),
                TextField(controller: _contentController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), maxLines: 4, decoration: InputDecoration(hintText: 'اكتب الذكرى...', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _tagController, style: TextStyle(color: textColor, fontSize: 13), decoration: InputDecoration(hintText: 'إضافة تاج', hintStyle: TextStyle(color: hintColor, fontSize: 13), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), isDense: true))),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.add_circle, color: AppColors.gold), onPressed: () { if (_tagController.text.trim().isNotEmpty) { setModalState(() => tags.add(_tagController.text.trim())); _tagController.clear(); } }),
                ]),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, children: tags.map((t) => Chip(label: Text('#$t', style: const TextStyle(fontSize: 11)), onDeleted: () => setModalState(() => tags.remove(t)), backgroundColor: AppColors.info.withOpacity(0.15), labelStyle: TextStyle(color: AppColors.info))).toList()),
                ],
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (_contentController.text.trim().isEmpty) return;
                    Provider.of<MemoryProvider>(context, listen: false).addMemory(MemoryItem(id: const Uuid().v4(), content: _contentController.text.trim(), category: _category, createdAt: DateTime.now(), tags: tags));
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ الذكرى'),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
