enum ChatMessageSender {
  user,
  ai,
}

enum ChatMessageStatus {
  sending,
  sent,
  error,
}

class ChatMessage {
  final String id;
  final String text;
  final ChatMessageSender sender;
  final DateTime timestamp;
  final ChatMessageStatus status;
  final String? errorMessage;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
    this.errorMessage,
  });

  bool get isUser => sender == ChatMessageSender.user;
  bool get isAi => sender == ChatMessageSender.ai;
  bool get isSending => status == ChatMessageStatus.sending;
  bool get hasError => status == ChatMessageStatus.error;

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatMessageSender? sender,
    DateTime? timestamp,
    ChatMessageStatus? status,
    String? errorMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender == ChatMessageSender.user ? 'user' : 'ai',
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final senderStr = (map['sender'] as String? ?? 'user').toLowerCase();
    final statusStr = (map['status'] as String? ?? 'sent').toLowerCase();

    ChatMessageStatus resolvedStatus;
    switch (statusStr) {
      case 'sending':
        resolvedStatus = ChatMessageStatus.sending;
        break;
      case 'error':
        resolvedStatus = ChatMessageStatus.error;
        break;
      default:
        resolvedStatus = ChatMessageStatus.sent;
    }

    return ChatMessage(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: map['text'] as String? ?? '',
      sender: senderStr == 'ai' ? ChatMessageSender.ai : ChatMessageSender.user,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      status: resolvedStatus,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
