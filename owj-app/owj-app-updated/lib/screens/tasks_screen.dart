import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/tasks_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final tabBarBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      children: [
        // TabBar with matching AppBar background
        Container(
          color: tabBarBg,
          child: TabBar(
            controller: tabController,
            labelColor: AppColors.gold,
            unselectedLabelColor: subColor,
            indicatorColor: AppColors.gold,
            tabs: const [
              Tab(text: 'All Tasks'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        // TabBarView fills remaining space
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTaskList(Provider.of<TasksProvider>(context).tasks, isDark),
              _buildTaskList(Provider.of<TasksProvider>(context).pendingTasks, isDark),
              _buildTaskList(Provider.of<TasksProvider>(context).completedTasks, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isDark) {
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: subColor),
            const SizedBox(height: 16),
            Text('No tasks yet', style: TextStyle(color: subColor, fontSize: 16)),
          ],
        ),
      );
    }

    return Consumer<TasksProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskCard(task, provider, isDark);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, TasksProvider provider, bool isDark) {
    final priorityColor = task.priority == 'high' ? AppColors.error : task.priority == 'medium' ? AppColors.warning : AppColors.success;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => provider.toggleTask(task.id),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? AppColors.success : Colors.transparent,
                  border: Border.all(color: task.isCompleted ? AppColors.success : subColor, width: 2),
                ),
                child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                    style: TextStyle(color: task.isCompleted ? subColor : textColor, fontSize: 15, fontWeight: FontWeight.w600, decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(task.description, style: TextStyle(color: subColor, fontSize: 12)),
                  ],
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: priorityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(task.priority == 'high' ? 'High' : task.priority == 'medium' ? 'Medium' : 'Low', style: TextStyle(color: priorityColor, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(task.category, style: TextStyle(color: AppColors.gold, fontSize: 10)),
                    ),
                  ]),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => provider.deleteTask(task.id)),
          ],
        ),
      ),
    );
  }

  void showAddTaskDialog(BuildContext context, bool isDark) {
    _titleController.clear();
    _descController.clear();
    _priority = 'medium';
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add New Task', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController, style: TextStyle(color: textColor),
                  decoration: InputDecoration(hintText: 'Task title', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController, style: TextStyle(color: textColor), maxLines: 3,
                  decoration: InputDecoration(hintText: 'Task description (optional)', hintStyle: TextStyle(color: hintColor), filled: true, fillColor: cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Priority:', style: TextStyle(color: hintColor)),
                  const SizedBox(width: 8),
                  _priorityChip('High', 'high', setModalState, isDark),
                  const SizedBox(width: 4),
                  _priorityChip('Medium', 'medium', setModalState, isDark),
                  const SizedBox(width: 4),
                  _priorityChip('Low', 'low', setModalState, isDark),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) return;
                      Provider.of<TasksProvider>(context, listen: false).addTask(Task(
                        id: const Uuid().v4(),
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        dueDate: DateTime.now(),
                        priority: _priority,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _priorityChip(String label, String value, StateSetter setModalState, bool isDark) {
    final isSelected = _priority == value;
    return GestureDetector(
      onTap: () => setModalState(() => _priority = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.darkBg : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight), fontSize: 12)),
      ),
    );
  }
}
