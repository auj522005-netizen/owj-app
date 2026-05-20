import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'type': type, 'time': time.toIso8601String(), 'isRead': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: j['id'], title: j['title'], body: j['body'],
    type: j['type'], time: DateTime.parse(j['time']), isRead: j['isRead'] ?? false,
  );
}

class NotificationProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  List<NotificationItem> _notifications = [];

  NotificationProvider(this.prefs) {
    _loadNotifications();
  }

  List<NotificationItem> get notifications => _notifications;
  List<NotificationItem> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _loadNotifications() {
    try {
      final data = prefs.getString('notifications_v2');
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        _notifications = list.map((e) => NotificationItem.fromJson(e)).toList();
      }
    } catch (_) {
      _notifications = [];
    }
    notifyListeners();
  }

  void _save() {
    final data = jsonEncode(_notifications.map((e) => e.toJson()).toList());
    prefs.setString('notifications_v2', data);
  }

  void addNotification({
    required String title,
    required String body,
    required String type,
  }) {
    _notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      time: DateTime.now(),
    ));
    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }
    _save();
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      _save();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) { n.isRead = true; }
    _save();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _save();
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _save();
    notifyListeners();
  }

  // Helper: add from AI action
  void notifyAIAction(String actionType, String itemTitle) {
    final messages = {
      'Task': 'Task added: $itemTitle',
      'Goal': 'Goal added: $itemTitle',
      'Habit': 'Habit added: $itemTitle',
      'Journal': 'Journal added: $itemTitle',
    };
    addNotification(
      title: messages[actionType] ?? 'Added: $itemTitle',
      body: 'AI executed the command automatically',
      type: actionType,
    );
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'Task': return Icons.task_alt;
      case 'Goal': return Icons.flag;
      case 'Habit': return Icons.repeat;
      case 'Reminder': return Icons.notifications_active;
      case 'Journal': return Icons.book;
      default: return Icons.notifications;
    }
  }

  Color getColorForType(String type) {
    switch (type) {
      case 'Task': return AppColors.warning;
      case 'Goal': return AppColors.gold;
      case 'Habit': return AppColors.success;
      case 'Reminder': return AppColors.info;
      case 'Journal': return const Color(0xFF9B59B6);
      default: return AppColors.gold;
    }
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
