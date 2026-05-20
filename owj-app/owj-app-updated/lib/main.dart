import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/goals_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/character_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/api_keys_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final prefs = await SharedPreferences.getInstance();
  runApp(OWJApp(prefs: prefs));
}

class OWJApp extends StatelessWidget {
  final SharedPreferences prefs;
  const OWJApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ApiKeysProvider(prefs)),
        ChangeNotifierProvider(create: (_) {
          final chatProvider = ChatProvider(prefs);
          // Wire up providers for tool calling after all are created
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // This will be called after the widget tree is built
          });
          return chatProvider;
        }),
        ChangeNotifierProvider(create: (_) => GoalsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HabitsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => TasksProvider(prefs)),
        ChangeNotifierProvider(create: (_) => JournalProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CharacterProvider(prefs)),
        ChangeNotifierProvider(create: (_) => MemoryProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(prefs)),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'OWJ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US')],
            builder: (context, child) {
              // Initialize chat provider with other providers after build
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
              final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
              final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
              final journalProvider = Provider.of<JournalProvider>(context, listen: false);
              final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
              chatProvider.setProviders(
                tasks: tasksProvider,
                goals: goalsProvider,
                habits: habitsProvider,
                journal: journalProvider,
                notifications: notifProvider,
              );
              return Directionality(
                textDirection: TextDirection.ltr,
                child: child!,
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
