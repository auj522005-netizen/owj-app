import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/habits_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '✅';
  String _frequency = 'daily';
  final List<String> _emojis = ['✅', '💪', '📚', '🏃', '🧘', '💧', '🎯', '💤', '🍎', '✍️', '🎵', '🧹'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('العادات')),
      body: Consumer<HabitsProvider>(
        builder: (context, provider, _) {
          if (provider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: subColor),
                  const SizedBox(height: 16),
                  Text('مفيش عادات لسه', style: TextStyle(color: subColor, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('اضغط + عشان تضيف عادة جديدة', style: TextStyle(color: subColor, fontSize: 13)),
                ],
              ),
            );
          }

          final completionRate = provider.todayCompletionRate;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('تقدم اليوم', style: TextStyle(color: subColor, fontSize: 14)),
                    Text('${(completionRate * 100).toInt()}%', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: completionRate, backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder, color: AppColors.gold, minHeight: 10)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.habits.length,
                  itemBuilder: (context, index) => _buildHabitCard(provider.habits[index], provider, isDark),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(isDark),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, HabitsProvider provider, bool isDark) {
    final isCompleted = habit.isCompletedToday();
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 10), color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          GestureDetector(
            onTap: () => provider.toggleHabitToday(habit.id),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? AppColors.success : (isDark ? AppColors.darkSurface : AppColors.lightBg), border: Border.all(color: isCompleted ? AppColors.success : AppColors.gold, width: 2)),
              child: Center(child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 22) : Text(habit.emoji, style: const TextStyle(fontSize: 20))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.name, style: TextStyle(color: isCompleted ? subColor : textColor, fontSize: 15, fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null), textDirection: TextDirection.rtl),
            const SizedBox(height: 4),
            Row(children: [
              Text('🔥 ${habit.streak}', style: TextStyle(color: AppColors.gold, fontSize: 13)),
              const SizedBox(width: 8),
              Text(habit.frequency == 'daily' ? 'يومي' : 'أسبوعي', style: TextStyle(color: subColor, fontSize: 12)),
            ]),
          ])),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => provider.deleteHabit(habit.id)),
        ]),
      ),
    );
  }

  void _showAddHabitDialog(bool isDark) {
    _nameController.clear();
    _selectedEmoji = '✅';
    _frequency = 'daily';
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

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
                Text('إضافة عادة جديدة', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, children: _emojis.map((e) => GestureDetector(
                  onTap: () => setModalState(() => _selectedEmoji = e),
                  child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _selectedEmoji == e ? AppColors.gold.withOpacity(0.3) : cardBg, borderRadius: BorderRadius.circular(10), border: _selectedEmoji == e ? Border.all(color: AppColors.gold, width: 2) : null), child: Center(child: Text(e, style: const TextStyle(fontSize: 20)))),
                )).toList()),
                const SizedBox(height: 16),
                TextField(controller: _nameController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), decoration: InputDecoration(hintText: 'اسم العادة', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                Row(children: [
                  Text('التكرار:', style: TextStyle(color: hintColor)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => setModalState(() => _frequency = 'daily'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: _frequency == 'daily' ? AppColors.gold : cardBg, borderRadius: BorderRadius.circular(8)), child: Text('يومي', style: TextStyle(color: _frequency == 'daily' ? AppColors.darkBg : subColor)))),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => setModalState(() => _frequency = 'weekly'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: _frequency == 'weekly' ? AppColors.gold : cardBg, borderRadius: BorderRadius.circular(8)), child: Text('أسبوعي', style: TextStyle(color: _frequency == 'weekly' ? AppColors.darkBg : subColor)))),
                ]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;
                    Provider.of<HabitsProvider>(context, listen: false).addHabit(Habit(id: const Uuid().v4(), name: _nameController.text.trim(), emoji: _selectedEmoji, frequency: _frequency));
                    Navigator.pop(context);
                  },
                  child: const Text('إضافة العادة'),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
