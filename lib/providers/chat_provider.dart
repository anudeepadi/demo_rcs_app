import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final _uuid = Uuid();

  void addTextMessage(String content, {bool isMe = true}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: isMe,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addGifMessage(String gifUrl, {bool isMe = true}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: gifUrl,
      isMe: isMe,
      timestamp: DateTime.now(),
      type: MessageType.gif,
      mediaUrl: gifUrl,
    );
    _messages.add(message);
    notifyListeners();
  }

  void sendMedia(String mediaPath, MessageType type) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: mediaPath,
      isMe: true,
      timestamp: DateTime.now(),
      type: type,
      mediaUrl: mediaPath,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addVideoMessage(String videoUrl, {bool isMe = true}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: videoUrl,
      isMe: isMe,
      timestamp: DateTime.now(),
      type: MessageType.video,
      mediaUrl: videoUrl,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addQuickReplyMessage(String content, List<QuickReply> suggestedReplies, {bool isMe = false}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: isMe,
      timestamp: DateTime.now(),
      type: MessageType.quickReply,
      suggestedReplies: suggestedReplies,
    );
    _messages.add(message);
    notifyListeners();
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;
    addTextMessage(content, isMe: true);
  }
}