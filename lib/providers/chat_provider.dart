import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import '../models/link_preview.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final _uuid = const Uuid();

  void addTextMessage(String text, {bool isUser = true}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addGifMessage(String gifUrl, {bool isUser = true}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: gifUrl,
      isUser: isUser,
      timestamp: DateTime.now(),
      type: MessageType.image,
      mediaUrl: gifUrl,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addLinkPreviewMessage(LinkPreview preview) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: preview.url,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.linkPreview,
      linkPreview: preview,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addBotMessage(ChatMessage message) {
    _messages.add(message.copyWith(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      isUser: false,
    ));
    notifyListeners();
  }

  void addQuickReplyMessage(List<QuickReply> quickReplies) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: 'Quick Replies',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.quickReplies,
      suggestedReplies: quickReplies,
    );
    _messages.add(message);
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}