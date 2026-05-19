import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/app_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => CharactersScreenState();
}

class CharactersScreenState extends State<CharactersScreen> with TickerProviderStateMixin {
  late AnimationController _selectionController;
  String? _justSelected;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Consumer<CharacterProvider>(
      builder: (context, provider, _) {
        final allChars = provider.allCharacters;
        return CustomScrollView(
          slivers: [
            // Active character hero
            SliverToBoxAdapter(
              child: _buildActiveHero(provider, isDark, textColor, subColor),
            ),
            // Characters grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < allChars.length) {
                      final char = allChars[index];
                      final isActive = provider.activeCharacter == char['name'];
                      final isCustom = index >= AppConstants.characters.length;
                      return _buildCharCard(context, char, isActive, provider, isCustom, index - AppConstants.characters.length, isDark, textColor, subColor);
                    }
                    return null;
                  },
                  childCount: allChars.length,
                ),
              ),
            ),
            // Add custom
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAddCustomCard(context, provider, isDark),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveHero(CharacterProvider provider, bool isDark, Color textColor, Color subColor) {
    final char = provider.allCharacters.firstWhere(
      (c) => c['name'] == provider.activeCharacter,
      orElse: () => AppConstants.characters[0],
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.2), AppColors.gold.withOpacity(0.05)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          // Large animated emoji
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)],
              ),
              child: Center(child: Text(char['emoji'] ?? '💬', style: const TextStyle(fontSize: 40))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(char['name'] ?? '', style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Text('نشط الآن', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(char['desc'] ?? '', style: TextStyle(color: subColor, fontSize: 12, height: 1.5), textDirection: TextDirection.rtl, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharCard(
    BuildContext context,
    Map<String, String> char,
    bool isActive,
    CharacterProvider provider,
    bool isCustom,
    int customIndex,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          provider.setActiveCharacter(char['name']!);
          Provider.of<ChatProvider>(context, listen: false).setCharacter(char['name']!);
          setState(() => _justSelected = char['name']);
          _selectionController.forward(from: 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${char['emoji']} ${char['name']} أصبح نشطاً'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      onLongPress: isCustom ? () => _confirmDelete(context, provider, customIndex, char['name'] ?? '') : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.1) : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.gold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isActive ? 2 : 0.5,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Emoji circle
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.gold.withOpacity(0.15) : (isDark ? AppColors.darkSurface : AppColors.lightBg),
                      shape: BoxShape.circle,
                      border: isActive ? Border.all(color: AppColors.gold, width: 1.5) : null,
                    ),
                    child: Center(child: Text(char['emoji'] ?? '🤖', style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    char['name'] ?? '',
                    style: TextStyle(color: isActive ? AppColors.gold : textColor, fontSize: 15, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    char['desc'] ?? '',
                    style: TextStyle(color: subColor, fontSize: 10, height: 1.4),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Active badge
            if (isActive)
              Positioned(
                top: 8, left: 8,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            // Custom badge
            if (isCustom)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.info.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('مخصص', style: TextStyle(color: AppColors.info, fontSize: 9)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CharacterProvider provider, int customIndex, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الشخصية', textDirection: TextDirection.rtl),
        content: Text('هتحذف شخصية "$name"؟', textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              provider.removeCustomCharacter(customIndex);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomCard(BuildContext context, CharacterProvider provider, bool isDark) {
    if (provider.customCharacters.length >= 5) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showAddCharacterDialog(context, provider, isDark),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'إضافة شخصية مخصصة (${provider.customCharacters.length}/5)',
              style: TextStyle(color: AppColors.gold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCharacterDialog(BuildContext context, CharacterProvider provider, bool isDark) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final systemController = TextEditingController();
    String emoji = '🤖';
    final emojis = ['🤖', '👩‍🏫', '👨‍⚕️', '🧙', '🎭', '🦊', '🐱', '🌟', '🔥', '💎', '🦁', '🎯'];
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text('شخصية مخصصة جديدة', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Selected emoji display
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: emojis.map((e) => GestureDetector(
                      onTap: () => setModalState(() => emoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: emoji == e ? AppColors.gold.withOpacity(0.3) : cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: emoji == e ? Border.all(color: AppColors.gold, width: 2) : null,
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'اسم الشخصية', hintStyle: TextStyle(color: hintColor),
                      filled: true, fillColor: cardBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.badge_outlined, color: hintColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: textColor),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'وصف مختصر (بيظهر في البطاقة)', hintStyle: TextStyle(color: hintColor),
                      filled: true, fillColor: cardBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: systemController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: textColor),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'تعليمات النظام - كيف تتكلم؟ إيه أسلوبها؟ إيه شخصيتها؟', hintStyle: TextStyle(color: hintColor, fontSize: 12),
                      filled: true, fillColor: cardBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة الشخصية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.darkBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty || systemController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الاسم وتعليمات النظام مطلوبين'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        provider.addCustomCharacter({
                          'name': nameController.text.trim(),
                          'emoji': emoji,
                          'desc': descController.text.trim(),
                          'system': systemController.text.trim(),
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$emoji ${nameController.text.trim()} تمت إضافتها'), backgroundColor: AppColors.success),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
