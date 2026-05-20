import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/api_keys_provider.dart';
import '../providers/character_provider.dart';
import '../providers/app_provider.dart';
import '../providers/notification_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _avatarBounceController;
  late AnimationController _avatarPulseController;
  late AnimationController _avatarIdleController;
  late Animation<double> _bounceAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _idleAnim;

  bool _isAvatarVisible = true;
  String _lastCharName = '';

  @override
  void initState() {
    super.initState();

    _avatarBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = CurvedAnimation(
      parent: _avatarBounceController,
      curve: Curves.elasticOut,
    );

    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _avatarPulseController, curve: Curves.easeInOut),
    );

    _avatarIdleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _idleAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _avatarIdleController, curve: Curves.easeInOut),
    );

    _avatarBounceController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _avatarBounceController.dispose();
    _avatarPulseController.dispose();
    _avatarIdleController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _isAvatarVisible = true);
    _avatarBounceController.forward(from: 0);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final apiKeys = Provider.of<ApiKeysProvider>(context, listen: false);
    await chatProvider.sendMessage(text, apiKeys);
    _scrollToBottom();
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

  void showModelPicker(BuildContext context, ApiKeysProvider apiKeys, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose AI Model',
              style: TextStyle(color: AppColors.gold, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: AppConstants.aiProviders.map((provider) {
                  final isSelected = apiKeys.selectedModel == provider;
                  final storageKey = _storageKeyFor(provider);
                  final hasKey = apiKeys.getKey(storageKey).isNotEmpty;
                  final model = AppConstants.aiModels[provider] ?? '';
                  final caps = (AppConstants.modelCapabilities[provider] ?? []).take(3).join(' · ');

                  return GestureDetector(
                    onTap: hasKey ? () {
                      apiKeys.setSelectedModel(provider);
                      Navigator.pop(ctx);
                    } : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withOpacity(0.15)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: hasKey
                                  ? (isSelected ? AppColors.gold.withOpacity(0.2) : AppColors.success.withOpacity(0.1))
                                  : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              AppConstants.apiKeyIcons[storageKey] ?? Icons.smart_toy,
                              color: hasKey ? (isSelected ? AppColors.gold : AppColors.success) : Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      provider,
                                      style: TextStyle(
                                        color: hasKey
                                            ? (isSelected ? AppColors.gold : (isDark ? Colors.white : Colors.black87))
                                            : Colors.grey,
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          model,
                                          style: TextStyle(
                                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                            fontSize: 9,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  caps,
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!hasKey)
                            Text('No API Key', style: TextStyle(color: Colors.grey, fontSize: 10))
                          else if (isSelected)
                            Icon(Icons.check_circle, color: AppColors.gold, size: 22),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Clear all messages?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearMessages();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void showNotificationsSheet(BuildContext context, NotificationProvider provider, bool isDark) {
    if (provider.notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notifications right now'), duration: Duration(seconds: 2)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () { provider.markAllAsRead(); Navigator.pop(ctx); },
                    child: Text('Mark all read', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                  ),
                  Text('Notifications', style: TextStyle(color: AppColors.gold, fontSize: 17, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { provider.clearAll(); Navigator.pop(ctx); },
                    child: Text('Clear all', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: provider.notifications.length,
                itemBuilder: (_, i) {
                  final n = provider.notifications[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: provider.getColorForType(n.type).withOpacity(0.15),
                      child: Icon(provider.getIconForType(n.type), color: provider.getColorForType(n.type), size: 18),
                    ),
                    title: Text(n.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(n.body,
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12),
                    ),
                    trailing: !n.isRead
                        ? Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle))
                        : null,
                    onTap: () => provider.markAsRead(n.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppProvider>(context, listen: true).isDarkMode;
    final apiKeys = Provider.of<ApiKeysProvider>(context, listen: true);
    final charProvider = Provider.of<CharacterProvider>(context, listen: true);

    final char = charProvider.allCharacters.firstWhere(
      (c) => c['name'] == charProvider.activeCharacter,
      orElse: () => AppConstants.characters[0],
    );

    if (_lastCharName != charProvider.activeCharacter) {
      _lastCharName = charProvider.activeCharacter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _avatarBounceController.forward(from: 0);
        setState(() => _isAvatarVisible = true);
      });
    }

    return Column(
      children: [
        Consumer<ChatProvider>(
          builder: (context, chat, _) {
            return Column(
              children: [
                if (chat.activeProvider.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: AppColors.gold.withOpacity(0.15),
                    child: Text(
                      'Using: ${chat.activeProvider} · ${AppConstants.aiModels[apiKeys.selectedModel] ?? ''}',
                      style: TextStyle(color: AppColors.gold, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (chat.isSearching)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppColors.info.withOpacity(0.15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info)),
                        const SizedBox(width: 8),
                        Text('Searching for: ${chat.searchQuery}', style: TextStyle(color: AppColors.info, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.messages.isEmpty) {
                return _buildWelcome(isDark, char);
              }
              return Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                    itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatProvider.messages.length) {
                        return _buildTypingIndicator(isDark, char);
                      }
                      final msg = chatProvider.messages[index];
                      return _buildMessageBubble(msg, isDark, char);
                    },
                  ),
                  if (_isAvatarVisible)
                    Positioned(
                      bottom: 16, right: 16,
                      child: _buildFloatingAvatar(char, isDark, chatProvider.isLoading),
                    ),
                ],
              );
            },
          ),
        ),
        Consumer<ChatProvider>(
          builder: (context, chat, _) {
            if (chat.toolResults.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.success.withOpacity(0.1),
              child: Wrap(
                spacing: 8, runSpacing: 4,
                children: chat.toolResults.map((r) => Chip(
                  avatar: Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  label: Text('${r.type}: ${r.title}', style: TextStyle(color: AppColors.success, fontSize: 11)),
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                )).toList(),
              ),
            );
          },
        ),
        _buildInputArea(isDark),
      ],
    );
  }

  Widget _buildFloatingAvatar(Map<String, String> char, bool isDark, bool isLoading) {
    return ScaleTransition(
      scale: _bounceAnim,
      child: AnimatedBuilder(
        animation: _idleAnim,
        builder: (context, child) => Transform.translate(offset: Offset(0, _idleAnim.value), child: child),
        child: GestureDetector(
          onTap: () => setState(() => _isAvatarVisible = false),
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(scale: isLoading ? _pulseAnim.value : 1.0, child: child),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                shape: BoxShape.circle,
                border: Border.all(color: isLoading ? AppColors.info : AppColors.gold, width: isLoading ? 2 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (isLoading ? AppColors.info : AppColors.gold).withOpacity(0.35),
                    blurRadius: 14, spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(child: Text(char['emoji'] ?? '💬', style: const TextStyle(fontSize: 28))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(bool isDark, Map<String, String> char) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _bounceAnim,
                child: AnimatedBuilder(
                  animation: _idleAnim,
                  builder: (context, child) => Transform.translate(offset: Offset(0, _idleAnim.value * 0.5), child: child),
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2),
                      boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 20, spreadRadius: 4)],
                    ),
                    child: Center(child: Text(char['emoji'] ?? '💬', style: const TextStyle(fontSize: 50))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(char['name'] ?? 'OWJ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.gold)),
              const SizedBox(height: 8),
              Text(
                char['desc'] ?? '',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _suggestionChip('Add a task to finish my project', isDark),
              const SizedBox(height: 8),
              _suggestionChip('Make a plan for my day', isDark),
              const SizedBox(height: 8),
              _suggestionChip('Search for latest tech news', isDark),
              const SizedBox(height: 8),
              _suggestionChip('Help me organize my goals', isDark),
              const SizedBox(height: 8),
              _suggestionChip('Add a habit of drinking water', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String text, bool isDark) {
    return ActionChip(
      label: Text(text),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      labelStyle: TextStyle(color: AppColors.gold, fontSize: 13),
      side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
      onPressed: () { _controller.text = text; _sendMessage(); },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, Map<String, String> char) {
    final isUser = msg.isUser;
    final bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final userBg = AppColors.gold.withOpacity(0.15);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(left: 6, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Center(child: Text(char['emoji'] ?? '💬', style: const TextStyle(fontSize: 16))),
            ),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: msg.isToolResult ? AppColors.success.withOpacity(0.1) : (isUser ? userBg : bgColor),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 4 : 16),
                  bottomRight: Radius.circular(isUser ? 16 : 4),
                ),
                border: Border.all(
                  color: msg.isToolResult ? AppColors.success.withOpacity(0.3) :
                    (isUser ? AppColors.gold.withOpacity(0.3) : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(msg.content, style: TextStyle(color: isUser ? AppColors.gold : textColor, fontSize: 15, height: 1.5)),
                  if (msg.provider != null && !isUser) ...[
                    const SizedBox(height: 4),
                    Text(msg.provider!, style: TextStyle(color: AppColors.textSecondary, fontSize: 9), textDirection: TextDirection.ltr),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, Map<String, String> char) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(left: 6, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Center(child: Text(char['emoji'] ?? '💬', style: const TextStyle(fontSize: 16))),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_dot(0), const SizedBox(width: 4), _dot(1), const SizedBox(width: 4), _dot(2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 180)),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)));
      },
    );
  }

  Widget _buildInputArea(bool isDark) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final fillColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: textColor, fontSize: 15),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, chat, _) {
              return Container(
                decoration: BoxDecoration(
                  color: chat.isLoading ? AppColors.gold.withOpacity(0.5) : AppColors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: IconButton(
                  icon: chat.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.darkBg, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: AppColors.darkBg, size: 20),
                  onPressed: chat.isLoading ? null : _sendMessage,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
