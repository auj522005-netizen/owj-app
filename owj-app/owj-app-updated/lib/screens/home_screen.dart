import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/api_keys_provider.dart';
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

  final List<Widget> _screens = [
    const ChatScreen(),
    const TasksScreen(),
    const GoalsScreen(),
    const HabitsScreen(),
    const JournalScreen(),
    const MemoryScreen(),
    const CharactersScreen(),
    const SettingsScreen(),
  ];

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
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activeColor = AppColors.gold;
    final inactiveColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
