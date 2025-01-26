import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';

class SystemChatProvider with ChangeNotifier {
  final String systemUserId = 'system';
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendSystemMessage(String content) async {
    final message = ChatMessage(
      senderId: systemUserId,
      type: MessageType.text,
      content: content,
      isMe: false,
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendSystemMedia({
    required String mediaUrl,
    required MessageType type,
    String? caption,
  }) async {
    final message = ChatMessage(
      senderId: systemUserId,
      type: type,
      content: caption ?? '',
      isMe: false,
      mediaUrl: mediaUrl,
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendSystemQuickReplies({
    required List<QuickReply> replies,
    String? content,
  }) async {
    final message = ChatMessage(
      senderId: systemUserId,
      type: MessageType.quickReply,
      content: content ?? '',
      isMe: false,
      suggestedReplies: replies.map((r) => r.text).toList(),
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}