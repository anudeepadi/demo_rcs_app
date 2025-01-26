import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import '../models/link_preview.dart';
import 'package:uuid/uuid.dart';

class SystemChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final _uuid = Uuid();

  List<QuickReply> _defaultQuickReplies = [
    QuickReply(
      id: '1',
      text: 'Help',
      icon: Icons.help,
    ),
    QuickReply(
      id: '2',
      text: 'Settings',
      icon: Icons.settings,
    ),
    QuickReply(
      id: '3',
      text: 'About',
      icon: Icons.info,
    ),
  ];

  // Add a user message to the chat
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isMe: true, // User is the sender
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _messages.add(message);
    notifyListeners();
  }

  // Add a system-generated GIF message
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

  // Add a system-generated link preview message
  void addLinkPreviewMessage(String url, String? title, String? description, String? imageUrl, {bool isMe = true}) {
    final preview = LinkPreview(
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );

    final message = ChatMessage(
      id: _uuid.v4(),
      content: url,
      isMe: isMe,
      timestamp: DateTime.now(),
      type: MessageType.linkPreview,
      linkPreview: preview,
    );
    _messages.add(message);
    notifyListeners();
  }
}
