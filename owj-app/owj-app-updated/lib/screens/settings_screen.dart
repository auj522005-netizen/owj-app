import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/api_keys_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscured = {};
  final Map<String, bool> _editing = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in _controllers.values) { c.dispose(); }
    super.dispose();
  }

  TextEditingController _controllerFor(String key, String currentValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: currentValue);
      _obscured[key] = true;
      _editing[key] = false;
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final apiKeys = Provider.of<ApiKeysProvider>(context);
    final isDark = appProvider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: subColor,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy, size: 18), text: 'الذكاء'),
            Tab(icon: Icon(Icons.key, size: 18), text: 'المفاتيح'),
            Tab(icon: Icon(Icons.tune, size: 18), text: 'عام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAITab(apiKeys, isDark, textColor, subColor, cardColor),
          _buildKeysTab(apiKeys, isDark, textColor, subColor, cardColor),
          _buildGeneralTab(appProvider, apiKeys, isDark, textColor, subColor, cardColor),
        ],
      ),
    );
  }

  // ─────────────────── AI MODELS TAB ───────────────────
  Widget _buildAITab(ApiKeysProvider apiKeys, bool isDark, Color textColor, Color subColor, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('اختار الموديل النشط', isDark),
        const SizedBox(height: 12),
        ...AppConstants.aiProviders.map((provider) {
          final isSelected = apiKeys.selectedModel == provider;
          final storageKey = _storageKeyFor(provider);
          final hasKey = apiKeys.getKey(storageKey).isNotEmpty;
          final model = AppConstants.aiModels[provider] ?? '';
          final caps = AppConstants.modelCapabilities[provider] ?? [];

          return GestureDetector(
            onTap: hasKey ? () => apiKeys.setSelectedModel(provider) : () => _showNoKeySnackbar(provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold.withOpacity(0.1) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.gold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Provider icon circle
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: hasKey
                          ? (isSelected ? AppColors.gold.withOpacity(0.15) : AppColors.success.withOpacity(0.1))
                          : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppConstants.apiKeyIcons[storageKey] ?? Icons.smart_toy,
                        color: hasKey ? (isSelected ? AppColors.gold : AppColors.success) : Colors.grey,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(provider, style: TextStyle(color: isSelected ? AppColors.gold : textColor, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                              const SizedBox(width: 8),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: Text('نشط', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(model, style: TextStyle(color: AppColors.info, fontSize: 11), textDirection: TextDirection.ltr),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4, runSpacing: 4,
                            children: caps.map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c, style: TextStyle(color: subColor, fontSize: 10)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    // Status
                    Column(
                      children: [
                        if (!hasKey)
                          Icon(Icons.lock_outline, color: Colors.grey, size: 20)
                        else if (isSelected)
                          Icon(Icons.check_circle, color: AppColors.gold, size: 24)
                        else
                          Icon(Icons.radio_button_unchecked, color: AppColors.success, size: 22),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        _sectionHeader('إضافة موديلات مخصصة عبر OpenRouter', isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'لو عندك OpenRouter API، تقدر توصل لأكتر من 100 موديل مجاناً ومدفوع زي Claude و GPT-4 وغيرهم.',
                  style: TextStyle(color: AppColors.info, fontSize: 12, height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────── API KEYS TAB ───────────────────
  Widget _buildKeysTab(ApiKeysProvider apiKeys, bool isDark, Color textColor, Color subColor, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56, height: 56,
                    child: CircularProgressIndicator(
                      value: apiKeys.activeKeyCount / apiKeys.totalKeyCount,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      strokeWidth: 4,
                    ),
                  ),
                  Text('${apiKeys.activeKeyCount}', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${apiKeys.activeKeyCount} من ${apiKeys.totalKeyCount} مفاتيح نشطة', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    const SizedBox(height: 4),
                    Text('كل مفتاح بيخلي ميزة جديدة تشتغل', style: TextStyle(color: subColor, fontSize: 12), textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  apiKeys.resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('تم استعادة المفاتيح الافتراضية'), backgroundColor: AppColors.success),
                  );
                },
                child: Text('استعادة', style: TextStyle(color: AppColors.gold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _sectionHeader('مفاتيح الذكاء الاصطناعي', isDark),
        const SizedBox(height: 8),
        _keyTile(apiKeys, AppConstants.geminiKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.groqKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.bigmodelKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.openrouterKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.openaiKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.cerebrasKey, isDark, textColor, subColor, cardColor),
        const SizedBox(height: 20),

        _sectionHeader('خدمات البحث والذاكرة والصوت', isDark),
        const SizedBox(height: 8),
        _keyTile(apiKeys, AppConstants.mem0Key, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.tavilyKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.tavilyMcpKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.elevenlabsKey, isDark, textColor, subColor, cardColor),
        const SizedBox(height: 20),

        _sectionHeader('تكاملات خارجية', isDark),
        const SizedBox(height: 8),
        _keyTile(apiKeys, AppConstants.githubKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.notionKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.youtubeKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.gmailClientIdKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.gmailClientSecretKey, isDark, textColor, subColor, cardColor),
        const SizedBox(height: 20),

        _sectionHeader('Firebase', isDark),
        const SizedBox(height: 8),
        _keyTile(apiKeys, AppConstants.firebaseApiKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.firebaseProjectIdKey, isDark, textColor, subColor, cardColor),
        _keyTile(apiKeys, AppConstants.firebaseAppIdKey, isDark, textColor, subColor, cardColor),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _keyTile(ApiKeysProvider apiKeys, String storageKey, bool isDark, Color textColor, Color subColor, Color cardColor) {
    final label = AppConstants.apiKeyLabels[storageKey] ?? storageKey;
    final icon = AppConstants.apiKeyIcons[storageKey] ?? Icons.key;
    final currentValue = apiKeys.getKey(storageKey);
    final hasKey = currentValue.isNotEmpty;
    final ctrl = _controllerFor(storageKey, currentValue);
    final isObscured = _obscured[storageKey] ?? true;
    final isEditing = _editing[storageKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasKey ? AppColors.success.withOpacity(0.4) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: hasKey ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: hasKey ? AppColors.success.withOpacity(0.12) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: hasKey ? AppColors.success : subColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500), textDirection: TextDirection.rtl),
                ),
                if (hasKey)
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _editing[storageKey] = !isEditing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEditing ? AppColors.gold.withOpacity(0.15) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isEditing ? 'إغلاق' : (hasKey ? 'تعديل' : 'إضافة'),
                      style: TextStyle(color: isEditing ? AppColors.gold : subColor, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Editing area
          if (isEditing)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          obscureText: isObscured,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(color: textColor, fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'الصق المفتاح هنا...',
                            hintStyle: TextStyle(color: subColor, fontSize: 12),
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            suffixIcon: IconButton(
                              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, size: 18, color: subColor),
                              onPressed: () => setState(() => _obscured[storageKey] = !isObscured),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hasKey)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                            label: Text('حذف', style: TextStyle(color: AppColors.error, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              apiKeys.removeKey(storageKey);
                              ctrl.clear();
                              setState(() => _editing[storageKey] = false);
                            },
                          ),
                        ),
                      if (hasKey) const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text('حفظ', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.darkBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            final val = ctrl.text.trim();
                            if (val.isNotEmpty) {
                              apiKeys.setKey(storageKey, val);
                              setState(() => _editing[storageKey] = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم حفظ مفتاح $label'), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────── GENERAL TAB ───────────────────
  Widget _buildGeneralTab(AppProvider appProvider, ApiKeysProvider apiKeys, bool isDark, Color textColor, Color subColor, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold.withOpacity(0.15), AppColors.gold.withOpacity(0.05)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text('أوج', style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أوج - مرشدك الذكي', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    const SizedBox(height: 4),
                    Text('الإصدار ${AppConstants.appVersion}', style: TextStyle(color: subColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('مصنوع بـ ❤️ للعرب', style: TextStyle(color: subColor, fontSize: 11), textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionHeader('المظهر', isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
          child: SwitchListTile(
            title: Text('الوضع الليلي', style: TextStyle(color: textColor, fontSize: 15)),
            subtitle: Text(isDark ? 'وضع داكن' : 'وضع فاتح', style: TextStyle(color: subColor, fontSize: 12)),
            secondary: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.gold, size: 18),
            ),
            activeColor: AppColors.gold,
            value: isDark,
            onChanged: (val) => appProvider.setDarkMode(val),
          ),
        ),
        const SizedBox(height: 24),

        _sectionHeader('البيانات', isDark),
        const SizedBox(height: 8),
        _settingsTile(
          icon: Icons.restore,
          iconColor: AppColors.info,
          title: 'استعادة مفاتيح API الافتراضية',
          subtitle: 'يرجع كل المفاتيح للقيم الافتراضية',
          isDark: isDark, textColor: textColor, subColor: subColor, cardColor: cardColor,
          onTap: () {
            _showConfirmDialog(
              context: context,
              title: 'استعادة المفاتيح',
              body: 'هترجع كل المفاتيح للافتراضية؟',
              onConfirm: () {
                apiKeys.resetToDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('تم استعادة المفاتيح الافتراضية'), backgroundColor: AppColors.success),
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        _settingsTile(
          icon: Icons.copy,
          iconColor: AppColors.warning,
          title: 'نسخ حالة النظام',
          subtitle: 'نسخ معلومات التطبيق للتشخيص',
          isDark: isDark, textColor: textColor, subColor: subColor, cardColor: cardColor,
          onTap: () {
            final info = 'أوج v${AppConstants.appVersion}\nالموديل: ${apiKeys.selectedModel}\nالمفاتيح النشطة: ${apiKeys.activeKeyCount}/${apiKeys.totalKeyCount}';
            Clipboard.setData(ClipboardData(text: info));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم النسخ'), duration: Duration(seconds: 2)),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color textColor,
    required Color subColor,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500), textDirection: TextDirection.rtl),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: subColor, fontSize: 11), textDirection: TextDirection.rtl),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: subColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
        ],
      ),
    );
  }

  String _storageKeyFor(String provider) {
    switch (provider) {
      case 'Gemini': return AppConstants.geminiKey;
      case 'Groq': return AppConstants.groqKey;
      case 'BigModel': return AppConstants.bigmodelKey;
      case 'OpenRouter': return AppConstants.openrouterKey;
      case 'OpenAI': return AppConstants.openaiKey;
      case 'Cerebras': return AppConstants.cerebrasKey;
      default: return AppConstants.geminiKey;
    }
  }

  void _showNoKeySnackbar(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('لازم تضيف مفتاح API لـ $provider الأول'),
        backgroundColor: AppColors.warning,
        action: SnackBarAction(
          label: 'إضافة',
          textColor: AppColors.darkBg,
          onPressed: () => _tabController.animateTo(1),
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String body,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, textDirection: TextDirection.rtl),
        content: Text(body, textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
