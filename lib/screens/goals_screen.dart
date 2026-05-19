import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/goals_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => GoalsScreenState();
}

class GoalsScreenState extends State<GoalsScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _milestoneController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Consumer<GoalsProvider>(
      builder: (context, provider, _) {
        if (provider.goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag, size: 64, color: subColor),
                const SizedBox(height: 16),
                Text('مفيش أهداف لسه', style: TextStyle(color: subColor, fontSize: 16)),
                const SizedBox(height: 8),
                Text('اضغط + عشان تضيف هدف جديد', style: TextStyle(color: subColor, fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.goals.length,
          itemBuilder: (context, index) => _buildGoalCard(provider.goals[index], provider, isDark),
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal, GoalsProvider provider, bool isDark) {
    final progressPercent = (goal.progress * 100).toInt();
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(children: [
              Expanded(child: Text(goal.title, style: TextStyle(color: goal.isCompleted ? AppColors.success : textColor, fontSize: 17, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl)),
              if (goal.isCompleted) const Icon(Icons.check_circle, color: AppColors.success),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => provider.deleteGoal(goal.id)),
            ]),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(goal.description, style: TextStyle(color: subColor, fontSize: 13), textDirection: TextDirection.rtl),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Text('$progressPercent%', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: goal.progress, backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder, color: AppColors.gold, minHeight: 8),
              )),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.gold, size: 20), onPressed: () => provider.updateProgress(goal.id, goal.progress + 0.1)),
            ]),
            if (goal.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: goal.milestones.map((m) => Chip(
                label: Text(m, style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.gold.withOpacity(0.15),
                labelStyle: TextStyle(color: AppColors.gold),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList()),
            ],
          ],
        ),
      ),
    );
  }

  void showAddGoalDialog(BuildContext context, bool isDark) {
    _titleController.clear();
    _descController.clear();
    _milestoneController.clear();
    List<String> milestones = [];
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
                Text('إضافة هدف جديد', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: _titleController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), decoration: InputDecoration(hintText: 'عنوان الهدف', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                TextField(controller: _descController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor), maxLines: 2, decoration: InputDecoration(hintText: 'وصف الهدف', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _milestoneController, textDirection: TextDirection.rtl, style: TextStyle(color: textColor, fontSize: 13), decoration: InputDecoration(hintText: 'إضافة معلم', hintStyle: TextStyle(color: hintColor, fontSize: 13), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.add_circle, color: AppColors.gold), onPressed: () { if (_milestoneController.text.trim().isNotEmpty) { setModalState(() => milestones.add(_milestoneController.text.trim())); _milestoneController.clear(); } }),
                ]),
                if (milestones.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 4, children: milestones.map((m) => Chip(label: Text(m, style: const TextStyle(fontSize: 12)), onDeleted: () => setModalState(() => milestones.remove(m)), backgroundColor: AppColors.gold.withOpacity(0.15), labelStyle: TextStyle(color: AppColors.gold))).toList()),
                ],
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) return;
                    Provider.of<GoalsProvider>(context, listen: false).addGoal(Goal(id: const Uuid().v4(), title: _titleController.text.trim(), description: _descController.text.trim(), deadline: DateTime.now().add(const Duration(days: 30)), milestones: milestones));
                    Navigator.pop(context);
                  },
                  child: const Text('إضافة الهدف'),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
