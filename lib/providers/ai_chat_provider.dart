import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/ai_chat_service.dart';
import '../data/models/chat_message_model.dart';

class AiChatProvider extends ChangeNotifier {
  static const String _storageKey = 'english_buddy_ai_chat_history';

  final AiChatService _service;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastError;
  bool _isInitialized = false;

  AiChatProvider({AiChatService? service})
      : _service = service ?? AiChatService();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isConfigured => _service.isConfigured;
  String get endpointUrl => _service.endpointUrl;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo và khôi phục lịch sử chat đã lưu trên thiết bị
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _messages.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final msg = ChatMessage.fromMap(item);
            // Nếu có tin nhắn đang ở trạng thái sending bị lưu dở, đánh dấu thành error
            if (msg.status == ChatMessageStatus.sending) {
              _messages.add(msg.copyWith(
                status: ChatMessageStatus.error,
                errorMessage: 'Quá trình gửi câu hỏi bị gián đoạn.',
              ));
            } else {
              _messages.add(msg);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error restoring AI chat history: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveHistoryToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Giới hạn lưu tối đa 50 tin nhắn gần nhất để tối ưu hiệu năng
      final toSave = _messages.length > 50
          ? _messages.sublist(_messages.length - 50)
          : _messages;
      final encoded = jsonEncode(toSave.map((m) => m.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving AI chat history: $e');
    }
  }

  /// Gửi câu hỏi đến Trợ lý AI
  Future<void> sendMessage(String text, {String? idToken}) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _lastError = null;
    final now = DateTime.now();

    // 1. Thêm tin nhắn của người học
    final userMessage = ChatMessage(
      id: 'user_${now.millisecondsSinceEpoch}',
      text: query,
      sender: ChatMessageSender.user,
      timestamp: now,
      status: ChatMessageStatus.sent,
    );

    // 2. Tạo placeholder tin nhắn đang xử lý của AI
    final aiPlaceholderId = 'ai_${now.millisecondsSinceEpoch}';
    final aiPlaceholder = ChatMessage(
      id: aiPlaceholderId,
      text: '',
      sender: ChatMessageSender.ai,
      timestamp: now,
      status: ChatMessageStatus.sending,
    );

    _messages.add(userMessage);
    _messages.add(aiPlaceholder);
    _isLoading = true;
    notifyListeners();
    await _saveHistoryToStorage();

    // 3. Gọi dịch vụ Backend Worker
    final result = await _service.sendMessage(
      message: query,
      history: _messages.sublist(0, _messages.length - 1),
      idToken: idToken,
    );

    _isLoading = false;

    // 4. Cập nhật kết quả phản hồi của AI
    final aiIndex = _messages.indexWhere((m) => m.id == aiPlaceholderId);
    if (aiIndex != -1) {
      if (result.isSuccess && result.reply != null) {
        _messages[aiIndex] = _messages[aiIndex].copyWith(
          text: result.reply!,
          status: ChatMessageStatus.sent,
          errorMessage: null,
        );
      } else {
        final err = result.errorMessage ?? 'Không nhận được phản hồi từ AI.';
        _messages[aiIndex] = _messages[aiIndex].copyWith(
          text: '',
          status: ChatMessageStatus.error,
          errorMessage: err,
        );
        _lastError = err;
      }
    }

    notifyListeners();
    await _saveHistoryToStorage();
  }

  /// Thử gửi lại tin nhắn bị lỗi
  Future<void> retryMessage(String messageId, {String? idToken}) async {
    if (_isLoading) return;

    final targetIndex = _messages.indexWhere((m) => m.id == messageId);
    if (targetIndex == -1) return;

    final targetMessage = _messages[targetIndex];
    String queryToRetry = '';

    if (targetMessage.isUser) {
      queryToRetry = targetMessage.text;
      // Xóa tin nhắn AI bị lỗi liền sau nếu có
      if (targetIndex + 1 < _messages.length && _messages[targetIndex + 1].isAi) {
        _messages.removeAt(targetIndex + 1);
      }
      _messages.removeAt(targetIndex);
    } else {
      // Nếu là bubble lỗi của AI, tìm tin nhắn của user ngay trước nó
      if (targetIndex > 0 && _messages[targetIndex - 1].isUser) {
        queryToRetry = _messages[targetIndex - 1].text;
        _messages.removeAt(targetIndex); // Xóa bubble lỗi của AI
        _messages.removeAt(targetIndex - 1); // Xóa tin nhắn user để gửi lại mới
      }
    }

    if (queryToRetry.isNotEmpty) {
      await sendMessage(queryToRetry, idToken: idToken);
    }
  }

  /// Xóa toàn bộ lịch sử trò chuyện (cả bộ nhớ tạm và lưu trữ cục bộ)
  Future<void> clearChat() async {
    _messages.clear();
    _lastError = null;
    _isLoading = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error removing AI chat history: $e');
    }
  }
}
