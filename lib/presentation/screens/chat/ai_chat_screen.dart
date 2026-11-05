import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../providers/ai_chat_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  final List<String> _suggestedPrompts = [
    '💡 Phân biệt cách dùng "make" và "do" trong ngữ cảnh thực tế?',
    '📝 Sửa lỗi ngữ pháp giúp mình câu: "I look forward to see you soon."',
    '🔍 Dịch và phân tích cấu trúc: "It is high time we took action."',
    '🗣️ Khi nào nên dùng thì Hiện tại Hoàn thành thay vì Quá khứ Đơn?',
    '✍️ Góp ý giúp mình cách mở bài email tiếng Anh công việc tự nhiên hơn.',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatProvider = Provider.of<AiChatProvider>(context, listen: false);
    if (chatProvider.isLoading) return;

    String? idToken;
    Future<String?> Function()? onRefreshToken;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        idToken = auth.idToken;
        onRefreshToken = () => auth.refreshSessionToken();
      }
    } catch (_) {}

    _textController.clear();
    setState(() {
      _canSend = false;
    });

    chatProvider
        .sendMessage(
          trimmed,
          idToken: idToken,
          onRefreshToken: onRefreshToken,
        )
        .then((_) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _confirmClearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 8),
            Text(context.l10n.aiChatClearTitle),
          ],
        ),
        content: Text(
          context.l10n.aiChatClearDesc,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final chatProvider = Provider.of<AiChatProvider>(context, listen: false);
      await chatProvider.clearChat();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.aiChatClearSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Về Trợ lý AI English Buddy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Trợ lý AI được thiết kế chuyên biệt để đồng hành cùng bạn trong việc học tiếng Anh:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text('• Giải đáp câu hỏi ngữ pháp, phiên âm, từ vựng theo ngữ cảnh thực tế.'),
              Text('• Phân tích sâu cấu trúc câu và dịch song ngữ Anh - Việt.'),
              Text('• Góp ý bài viết (Writing feedback), phát hiện lỗi sai và gợi ý cách diễn đạt tự nhiên hơn.'),
              SizedBox(height: 12),
              Text(
                'Bảo mật & Máy chủ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Toàn bộ API Key và System Prompt được lưu an toàn trên Cloudflare Worker Backend, không bao giờ lộ trên ứng dụng máy khách.',
                style: TextStyle(fontSize: 12.5),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.actionUnderstood),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<AiChatProvider>(context);
    final messages = chatProvider.messages;
    final isConfigured = chatProvider.isConfigured;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: context.surfaceBg,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderCol, height: 1),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimaryColor),
          tooltip: context.l10n.actionBack,
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.l10n.aiChatTitle,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isConfigured
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isConfigured ? 'Trực tuyến' : 'Chưa cấu hình URL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isConfigured ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    context.l10n.aiChatSubtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: context.textSecondaryColor),
            tooltip: 'Thông tin Trợ lý AI',
            onPressed: _showInfoDialog,
          ),
          if (messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: context.textSecondaryColor),
              tooltip: context.l10n.aiChatClearTitle,
              onPressed: _confirmClearChat,
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              // Thông báo nếu backend chưa được cấu hình
              if (!isConfigured) _buildUnconfiguredBanner(context),

              // Danh sách tin nhắn hoặc Màn hình chào mừng
              Expanded(
                child: messages.isEmpty
                    ? _buildWelcomeState(context)
                    : _buildMessageList(context, chatProvider),
              ),

              // Ô nhập nội dung tin nhắn
              _buildInputArea(context, chatProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnconfiguredBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: context.isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend AI chưa được cấu hình URL',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: context.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Để bảo vệ secret an toàn, ứng dụng gọi AI qua Cloudflare Worker. Biên dịch kèm: --dart-define=AI_CHAT_BACKEND_URL=https://<worker-domain>/api/chat',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.aiChatGreeting,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.aiChatGreetingDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.aiChatSuggestions,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.textMutedColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ..._suggestedPrompts.map((prompt) => _buildSuggestionChip(context, prompt)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _textController.text = prompt;
          _focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: context.surfaceBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderCol),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: context.textMutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, AiChatProvider provider) {
    final messages = provider.messages;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: messages.length,
      itemBuilder: (ctx, index) {
        final message = messages[index];
        return _buildMessageBubble(context, message, provider);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    AiChatProvider provider,
  ) {
    final isUser = message.isUser;
    final isDark = context.isDark;

    if (message.isSending) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiAvatar(),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.aiChatThinking,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (message.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiAvatar(),
            const SizedBox(width: 10),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.dangerLightCol,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l10n.aiChatErrorGeneral,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.errorMessage ?? context.l10n.aiChatErrorGeneral,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        String? idToken;
                        Future<String?> Function()? onRefreshToken;
                        try {
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          if (auth.isAuthenticated) {
                            idToken = auth.idToken;
                            onRefreshToken = () => auth.refreshSessionToken();
                          }
                        } catch (_) {}
                        provider.retryMessage(
                          message.id,
                          idToken: idToken,
                          onRefreshToken: onRefreshToken,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.actionRetry,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Tin nhắn thông thường (User hoặc AI)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : context.surfaceBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: context.borderCol),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isUser ? Colors.white : context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.75)
                          : context.textMutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.primaryDark, size: 18),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildInputArea(BuildContext context, AiChatProvider provider) {
    final isLoading = provider.isLoading;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: _isDesktopOrWeb ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: KeyboardListener(
                focusNode: _focusNode,
                onKeyEvent: (event) {
                  if (_isDesktopOrWeb &&
                      event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _handleSend();
                  }
                },
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction:
                      _isDesktopOrWeb ? TextInputAction.none : TextInputAction.newline,
                  enabled: !isLoading,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: _isDesktopOrWeb
                        ? 'Nhập câu hỏi, câu cần dịch hoặc bài viết... (Enter để gửi, Shift+Enter xuống dòng)'
                        : context.l10n.aiChatInputPlaceholder,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: context.textMutedColor,
                    ),
                    filled: true,
                    fillColor: context.cardBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.borderCol),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              child: IconButton.filled(
                onPressed: (_canSend && !isLoading) ? () => _handleSend() : null,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                tooltip: 'Gửi câu hỏi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}