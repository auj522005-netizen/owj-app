import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/api_keys_provider.dart';
import '../providers/character_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/memory_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import 'chat_screen.dart';
import 'tasks_screen.dart';
import 'goals_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'memory_screen.dart';
import 'characters_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  // GlobalKeys to access child screen state
  final _chatKey = GlobalKey<ChatScreenState>();
  final _tasksKey = GlobalKey<TasksScreenState>();
  final _goalsKey = GlobalKey<GoalsScreenState>();
  final _habitsKey = GlobalKey<HabitsScreenState>();
  final _journalKey = GlobalKey<JournalScreenState>();
  final _memoryKey = GlobalKey<MemoryScreenState>();
  final _settingsKey = GlobalKey<SettingsScreenState>();

  final List<_NavItem> _navItems = [
    _NavItem('الشات', Icons.chat_bubble_rounded),
    _NavItem('المهام', Icons.task_alt_rounded),
    _NavItem('الأهداف', Icons.flag_rounded),
    _NavItem('العادات', Icons.repeat_rounded),
    _NavItem('المذكرات', Icons.book_rounded),
    _NavItem('الذاكرة', Icons.psychology_rounded),
    _NavItem('الشخصيات', Icons.smart_toy_rounded),
    _NavItem('الإعدادات', Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      ChatScreen(key: _chatKey),
      TasksScreen(key: _tasksKey),
      GoalsScreen(key: _goalsKey),
      HabitsScreen(key: _habitsKey),
      JournalScreen(key: _journalKey),
      MemoryScreen(key: _memoryKey),
      const CharactersScreen(),
      SettingsScreen(key: _settingsKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activeColor = AppColors.gold;
    final inactiveColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFAB(isDark),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? activeColor : inactiveColor,
                            size: isSelected ? 26 : 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? activeColor : inactiveColor,
                              fontSize: isSelected ? 10 : 9,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════ APP BAR ═══════════════════

  PreferredSizeWidget _buildAppBar(bool isDark) {
    switch (_currentIndex) {
      case 0:
        return _buildChatAppBar(isDark);
      case 1:
        return AppBar(title: const Text('المهام'));
      case 2:
        return AppBar(title: const Text('الأهداف'));
      case 3:
        return AppBar(title: const Text('العادات'));
      case 4:
        return AppBar(title: const Text('المذكرات'));
      case 5:
        return _buildMemoryAppBar(isDark);
      case 6:
        return AppBar(title: const Text('الشخصيات'));
      case 7:
        return AppBar(title: const Text('الإعدادات'));
      default:
        return AppBar(title: const Text('أوج'));
    }
  }

  /// Chat screen AppBar with character name, model picker, notifications, clear
  PreferredSizeWidget _buildChatAppBar(bool isDark) {
    final charProvider = Provider.of<CharacterProvider>(context, listen: true);
    final apiKeys = Provider.of<ApiKeysProvider>(context, listen: true);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: true);

    final char = charProvider.allCharacters.firstWhere(
      (c) => c['name'] == charProvider.activeCharacter,
      orElse: () => AppConstants.characters[0],
    );

    return AppBar(
      title: GestureDetector(
        onTap: () => _chatKey.currentState?.showModelPicker(context, apiKeys, isDark),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(char['emoji'] ?? '', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(char['name'] ?? 'أوج', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(apiKeys.selectedModel, style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 3),
                  Icon(Icons.expand_more, color: AppColors.gold, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              onPressed: () => _chatKey.currentState?.showNotificationsSheet(context, notifProvider, isDark),
            ),
            if (notifProvider.unreadCount > 0)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${notifProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => _chatKey.currentState?.showClearDialog(context),
        ),
      ],
    );
  }

  /// Memory screen AppBar with search toggle and sync
  PreferredSizeWidget _buildMemoryAppBar(bool isDark) {
    final isSearching = _memoryKey.currentState?.isSearching ?? false;

    return AppBar(
      title: const Text('الذاكرة'),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () => _memoryKey.currentState?.toggleSearch(),
        ),
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () => _memoryKey.currentState?.syncMemory(context),
        ),
      ],
    );
  }

  // ═══════════════════ FAB ═══════════════════

  Widget? _buildFAB(bool isDark) {
    switch (_currentIndex) {
      case 0: // Chat - no FAB
        return null;
      case 1: // Tasks
        return FloatingActionButton(
          onPressed: () => _tasksKey.currentState?.showAddTaskDialog(context, isDark),
          child: const Icon(Icons.add),
        );
      case 2: // Goals
        return FloatingActionButton(
          onPressed: () => _goalsKey.currentState?.showAddGoalDialog(context, isDark),
          child: const Icon(Icons.add),
        );
      case 3: // Habits
        return FloatingActionButton(
          onPressed: () => _habitsKey.currentState?.showAddHabitDialog(context, isDark),
          child: const Icon(Icons.add),
        );
      case 4: // Journal
        return FloatingActionButton(
          onPressed: () => _journalKey.currentState?.showAddEntryDialog(context, isDark),
          child: const Icon(Icons.add),
        );
      case 5: // Memory
        return FloatingActionButton(
          onPressed: () => _memoryKey.currentState?.showAddMemoryDialog(context, isDark),
          child: const Icon(Icons.add),
        );
      case 6: // Characters - no FAB (inline add button)
        return null;
      case 7: // Settings - no FAB
        return null;
      default:
        return null;
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
